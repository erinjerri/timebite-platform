# Implementation Roadmap

## Step 1: Establish Goal Loop Domain

- Update shared schemas and Swift models.
- Introduce frequency, sessions, completion history, reflections, streaks, summaries, and tags.
- Add migration adapters for old quarterly goals and task completions.

## Step 2: Build The Today Ritual

- Make Today the default product entry.
- Add daily intent selection.
- Show selected goals with checkmarks and a single primary timer action.

## Step 3: Connect Timer To Sessions

- Create session records on timer start.
- Persist running session state.
- Write completion history from completion actions.

## Step 4: Add Reflection

- Present optional reflection after completion.
- Store reflections by goal, session, and date.
- Surface recent reflections in day detail and dashboard.

## Step 5: Add Streaks And Calendar

- Compute streaks from completion history.
- Render monthly completion calendar.
- Support day detail with session and reflection records.

## Step 6: Rebuild Dashboard

- Show current streaks, weekly summary, monthly summary, recent reflections, and light insights.
- Keep analytics secondary.
- Remove or gate quarterly chart and cycle score from MVP navigation.

## Step 7: Reintroduce Analytics Carefully

- Project Goal Loop data into analytics views after MVP activation is working.
- Keep calculations explainable and derived.
- Avoid making analytics required to complete daily flow.

## Step 8: Add AI Later

- Add explicit opt-in and privacy disclosure before any AI call.
- Start with reflection synthesis and gentle prompt suggestions.
- Keep AI out of the critical path.
