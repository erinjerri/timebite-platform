# Phase 2 Capture Plan

Phase 2 adds goal capture through speech, camera, and paper planner sync. The core loop remains manual and trustworthy; capture is an assistant layer that helps fill goal fields faster.

## Entry Point

Replace the old Finance tab with a Chatbot tab. The tab is for assisted capture:

- speech-to-text goal setup
- camera scan of planner pages
- physical paper planner sync
- agent-generated draft goals
- user confirmation before saving

Finance becomes a Goals subsection under the Finance life area.

## Capture Modes

### Speech

User taps the speech bubble and talks through a goal. The agent extracts:

- life area
- goal focus
- title
- description
- deadline
- next action
- monthly tasks

### Computer Vision

User taps the camera icon and scans a planner page, handwritten goal sheet, or future TimeBite paper product. The agent extracts the same fields as speech capture.

### Planner Sync

The open-book icon represents the physical paper planner. This is where paper planner OCR, calendar import, and future brick-and-mortar products connect to the app.

## Confirmation Flow

After capture, TimeBite shows a draft card for each generated goal or changed field.

Each draft has two square controls:

- X in a square: reject or edit
- checkmark in a square: confirm

No captured goal should be saved without explicit confirmation.

## Privacy And Trust

- Explain what content is sent before capture.
- Keep manual entry available.
- Show field-by-field diffs when an existing goal is modified.
- Store rejected drafts only locally unless the user opts into diagnostics.
- Treat OCR and transcription as assistive, not authoritative.

## Implementation Sequence

1. Add Chatbot tab shell with speech, camera, and planner entry points.
2. Add local draft goal model.
3. Add speech-to-text capture with permission gating.
4. Add camera capture with permission gating.
5. Add agent extraction into draft goal fields.
6. Add square reject/confirm controls.
7. Save confirmed drafts into Goals.
8. Add planner sync for paper products.
