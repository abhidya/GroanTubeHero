# WorldV2 Missing Assets / TODO

## 2026-05-25 latest status

The 500+ active placed art gate is currently passing with existing promoted clean ArtAssets in active Studio.

| Gate | Status | Evidence |
| --- | --- | --- |
| `activePlacedArtInstances >= 500` | PASS | Latest Studio `WorldValidation.Run()` count: 4455. |
| No scripts under `Workspace.GTH_WorldV2` | PASS | Latest count: 0. |
| No visible placeholder violations | PASS | Latest count: 0. |
| No unaudited visible placements | PASS | Latest count: 0. |

## Remaining improvement TODOs

| Asset/user-story area | Status | Next action |
| --- | --- | --- |
| True unique NPC variety | TODO | Current pass uses repeated clean horde/vendor source families. Add more audited character/NPC families later if visual variety is still low. |
| Tour bus authored art | TODO | Current tour bus/spawn category passes count through existing WorldV2 dressing, but a distinct clean bus source should be promoted when a safe bus model is available. |
| Audience bleachers/stadium source | REJECTED FOR NOW | `Clean_StadiumCrowdSeats` exists but was not placed because it previously created bad oversized stadium-wall placement. Re-audit manually before use. |
