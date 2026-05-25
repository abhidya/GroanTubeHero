# WorldV2 Missing Assets / TODO

## 2026-05-25 latest status

The 500+ active placed art gate is currently passing with existing promoted clean ArtAssets in active Studio.

| Gate | Status | Evidence |
| --- | --- | --- |
| `activePlacedArtInstances >= 500` | PASS | Latest direct Studio `WorldValidation.Run()` count: 14778 (post-team runtime rerun blocked by StudioMCP WS disconnect). |
| No scripts under `Workspace.GTH_WorldV2` | PASS | Latest count: 0. |
| No visible placeholder violations | PASS | Latest count: 0. |
| No unaudited visible placements | PASS | Latest count: 0. |

## Remaining improvement TODOs

Post-team gameplay/UX code now includes prompt repair dialogue, visible horde movement cues, and menu outcome feedback. Remaining items below are visual-variety/polish backlog, not current validation blockers.


| Asset/user-story area | Status | Next action |
| --- | --- | --- |
| True unique NPC variety | BACKLOG | Current pass uses many audited placements and 512 mass brainrot NPC models, but true source-family uniqueness can still improve if more audited safe character packs are available. |
| Tour bus authored art | BACKLOG | Current tour bus/spawn category passes count through existing WorldV2 dressing; promote a distinct safe bus model only after audit/quarantine. |
| Audience bleachers/stadium source | REJECTED FOR NOW | `Clean_StadiumCrowdSeats` exists but was not placed because it previously created bad oversized stadium-wall placement. Re-audit manually before use. |
