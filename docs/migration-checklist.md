# Migration Checklist

Use this checklist to migrate existing code from the cycle/quarterly model to the Goal Loop MVP.

---

## Domain Models

- [ ] Add Goal Loop fields to shared domain model.
- [ ] Map old `goal_id` to `GoalID`.
- [ ] Map old `title` to `Intent` when no separate intent exists.
- [ ] Map old `category` or `pillar` to `Category`.
- [ ] Replace `quarter` and `target_minutes` as required MVP fields with optional legacy metadata.
- [ ] Add `Frequency`.
- [ ] Add `Sessions`.
- [ ] Add `CompletionHistory`.
- [ ] Add `Reflections`.
- [ ] Add `CurrentStreak` and `LongestStreak`.
- [ ] Add `WeeklySummary` and `MonthlySummary`.
- [ ] Add `Tags`.

## Persistence

- [ ] Create migration for existing local goal records.
- [ ] Preserve existing completed task timestamps as completion history where possible.
- [ ] Convert completed timer/task records into sessions.
- [ ] Backfill streaks from completion history.
- [ ] Mark quarterly rollup tables or payloads as legacy.

## iOS UI

- [ ] Make Today the primary entry surface.
- [ ] Replace analytics-first dashboard entry with daily intent.
- [ ] Tie timer controls to goal sessions.
- [ ] Add completion checkmarks to goal rows.
- [ ] Add post-session reflection sheet.
- [ ] Add monthly completion calendar.
- [ ] Move dense analytics behind later dashboard or hidden feature flag.

## Backend And Sync

- [ ] Update goal API payloads for Goal Loop fields.
- [ ] Stop accepting client-submitted computed streak values as authoritative.
- [ ] Compute streaks from completion events where backend is involved.
- [ ] Reframe quarterly rollups as optional analytics projection.
- [ ] Update Notion export to mirror Goal Loop records.

## QA

- [ ] Create a goal and set frequency.
- [ ] Set today's intent.
- [ ] Start, pause, resume, and complete a session.
- [ ] Confirm completion history writes correctly.
- [ ] Confirm streak updates from completion history.
- [ ] Add reflection after completion.
- [ ] Confirm monthly calendar cell updates.
- [ ] Confirm dashboard summary reflects the same source data.
