import { Client } from "@notionhq/client";
import { appendFile, readFile, rename, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const toolDirectory = dirname(fileURLToPath(import.meta.url));
const workspaceRoot = resolve(toolDirectory, "../..");
const tasksPath = resolve(toolDirectory, "release-tasks.json");
const statePath = resolve(toolDirectory, ".notion-sync-state.json");
const eventLogPath = resolve(workspaceRoot, "backend/services/telemetry/runs.jsonl");
const dataSourceID =
  process.env.NOTION_DATA_SOURCE_ID ?? "fd7cff99-db83-48f9-8f2b-14d393633d23";

if (!process.env.NOTION_TOKEN) {
  throw new Error("NOTION_TOKEN is required");
}

const notion = new Client({
  auth: process.env.NOTION_TOKEN,
  notionVersion: "2026-03-11"
});
const tasks = JSON.parse(await readFile(tasksPath, "utf8"));
const state = await readState();
let lastRequestAt = 0;
let failed = false;

for (const task of tasks) {
  try {
    const pageID = await findExistingPage(task);
    const properties = notionProperties(task);

    if (pageID) {
      await limitedRequest(() =>
        notion.pages.update({
          page_id: pageID,
          properties
        })
      );
      state[task.external_id] = { notion_page_id: pageID };
      console.log(`updated ${task.external_id}`);
    } else {
      const page = await limitedRequest(() =>
        notion.pages.create({
          parent: { type: "data_source_id", data_source_id: dataSourceID },
          properties
        })
      );
      state[task.external_id] = { notion_page_id: page.id };
      console.log(`created ${task.external_id}`);
    }

    await writeState();
  } catch (error) {
    failed = true;
    await logFailure(task, error);
    console.error(`failed ${task.external_id}: ${errorMessage(error)}`);
  }
}

if (failed) {
  process.exitCode = 1;
}

async function findExistingPage(task) {
  const storedPageID = state[task.external_id]?.notion_page_id;
  if (storedPageID) {
    try {
      await limitedRequest(() => notion.pages.retrieve({ page_id: storedPageID }));
      return storedPageID;
    } catch (error) {
      if (error?.status !== 404) throw error;
      delete state[task.external_id];
    }
  }

  const response = await limitedRequest(() =>
    notion.dataSources.query({
      data_source_id: dataSourceID,
      page_size: 2,
      filter: {
        and: [
          { property: "Task", title: { equals: task.task } },
          { property: "Milestone", rich_text: { equals: task.epic } }
        ]
      }
    })
  );

  if (response.results.length > 1) {
    throw new Error(`duplicate Notion rows found for ${task.external_id}`);
  }
  return response.results[0]?.id;
}

function notionProperties(task) {
  return {
    Task: { title: richText(task.task) },
    Status: { select: { name: "Not started" } },
    Priority: { select: { name: "P0" } },
    Platform: { select: { name: task.platform } },
    Track: { select: { name: "Apple" } },
    Phase: { select: { name: "Apple Readiness" } },
    Milestone: { rich_text: richText(task.epic) },
    "Repo Path": { rich_text: richText(task.repo_path) },
    Owner: { rich_text: richText("Erin + Codex") },
    "Record Type": { select: { name: "Feature" } },
    "Completion %": { number: 0 },
    "Estimated Time": { rich_text: richText(task.estimated_time) },
    Dependency: { rich_text: richText(task.dependency) },
    Deliverable: { rich_text: richText(task.deliverable) },
    Notes: { rich_text: richText(task.notes) },
    "Apple Required?": { checkbox: true },
    "Demo Critical?": { checkbox: true },
    "Blocks Build?": { checkbox: task.task.includes("build") || task.task.includes("SDK") },
    "Blocks Demo?": { checkbox: false },
    "Day Target": { date: { start: task.due } }
  };
}

function richText(value) {
  return value ? [{ type: "text", text: { content: value } }] : [];
}

async function limitedRequest(request) {
  const minimumIntervalMs = 334;
  const waitMs = Math.max(0, lastRequestAt + minimumIntervalMs - Date.now());
  if (waitMs > 0) {
    await new Promise((resolveDelay) => setTimeout(resolveDelay, waitMs));
  }
  lastRequestAt = Date.now();
  return request();
}

async function readState() {
  try {
    return JSON.parse(await readFile(statePath, "utf8"));
  } catch (error) {
    if (error?.code === "ENOENT") return {};
    throw error;
  }
}

async function writeState() {
  const temporaryPath = `${statePath}.tmp`;
  await writeFile(temporaryPath, `${JSON.stringify(state, null, 2)}\n`);
  await rename(temporaryPath, statePath);
}

async function logFailure(task, error) {
  const event = {
    schema: "AgentActionEvent",
    event_type: "notion_pm_sync",
    outcome: "failed",
    external_id: task.external_id,
    notion_page_id: state[task.external_id]?.notion_page_id ?? null,
    occurred_at: new Date().toISOString(),
    error: errorMessage(error)
  };
  await appendFile(eventLogPath, `${JSON.stringify(event)}\n`);
}

function errorMessage(error) {
  return error instanceof Error ? error.message : String(error);
}
