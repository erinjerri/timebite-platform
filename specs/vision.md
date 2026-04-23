# TimeBite Vision

TimeBite helps ambitious knowledge workers intentionally allocate time, execute with focus, and reflect on reality—using dynamic ring-based interfaces that make progress *felt*.

TimeBite is not “yet another to‑do list”. It is a lightweight operating system for a day:
- **Decide** what matters (Daily Intent).
- **Execute** what matters (Ring Timer).
- **Learn** from what happened (Reflection + Dashboard).

## Product thesis

Knowledge workers don’t fail because they can’t create tasks—they fail because:
- the day gets fragmented and reactive,
- execution lacks a single “now” surface,
- progress is invisible until it’s too late,
- reflection is separate from planning and therefore skipped.

TimeBite’s rings convert abstract intention into a tangible budget of minutes and attention, then closes the loop with execution evidence and reflection.

TimeBite helps users make hard tradeoffs visible.

Not every project deserves equal time.

The product helps users allocate finite life energy intentionally.

## Core insight (the assumption shift)

Most productivity apps assume:
- infinite time
- static 9–5 schedules
- tasks without energy costs
- projects without caps
- no forced tradeoffs

TimeBite assumes:
- finite hours
- changing energy
- multiple concurrent repos/projects
- weekly caps
- measurable outcomes
- projects paused / resumed

## North Star outcome

Users should be able to answer, in under 10 seconds:
1. **What matters today?**
2. **What should I do now?**
3. **Did I do what I intended?**

## Target users (initial)

- PMs, founders, and technical operators with high autonomy and high context-switch cost
- People who already “know what to do” but struggle to protect time against reactivity

Non-target (initial):
- heavy team project management replacements
- full calendar clients
- long-form journaling apps

## Core loop (iPhone first)

1. **Daily Intent planning**
2. **Focus lanes**
3. **Ring timer execution**
4. **Reflection journaling**
5. **Dashboard analytics**

Capture (voice + vision) and AI workflow assistance accelerate the loop; they do not replace it.

## Principles (non-negotiable)

1. **iPhone first**
   - watchOS/macOS/visionOS are follow-ons, not parallel launches.
2. **Local-first by default**
   - the app is useful with no account, no network, and no backend.
3. **Execution truth**
   - dashboards are driven by session logs, not self-reported “done” states alone.
4. **Small surface area**
   - the app stays calm: few lanes, few visible tasks, one active timer.
5. **Privacy as product**
   - reflections and capture data are sensitive; treat them as such.
6. **Composable growth**
   - optional sync and integrations should layer on without rewriting the iOS core.
7. **Finite weekly hours + concurrent projects**
   - users manage multiple projects with weekly caps; tradeoffs are explicit.

## Platform expansion (later)

- **watchOS:** “Now” + one-tap execution companion
- **macOS:** planning + review + debugging surface (power-user workflows)
- **visionOS:** spatial rings as an ambient status board and deep focus mode

## Definition of success (launch)

Launch success is not downloads; it’s repeatable behavior change:
- Weekly retention on the iPhone MVP
- Users completing Daily Intent + at least one timed session on most weekdays
- Reflections that alter next-day plans (closed feedback loop)

## Source of truth

Requirements and acceptance criteria live in:
- `specs/master-requirements.md`
- `product/` PRDs for feature-level detail
