# Troubleshooting lessons from the actual platform

These are historical engineering incidents summarized from maintained internal records. They are not newly reproduced tests, a fresh cloud inventory or instructions to repeat a consumed operation. Names, resource identifiers, private payloads and credentials are excluded.

## Pausing applications did not pause endpoint charges

**What happened.** Nonproduction compute was paused while private endpoints remained provisioned and continued to have an hourly cost.

**What the evidence showed.** The November 6 inventory identified thirteen nonproduction endpoints. It also established that production used a state-storage account located in the nonproduction environment through its own separate production endpoint and DNS path. Environment names alone were not safe deletion boundaries.

**What changed and how it was checked.** The owner-authorized operation removed only the reviewed nonproduction endpoints, preserved the shared account and production paths, retained restoration metadata and restored the recovery-account deletion lock. Data, identities and public-access restrictions remained in place.

**What to carry forward.** A private endpoint has no paused power state. Evaluate exact consumers before removing a path, and restore the reviewed private paths before nonproduction publication or testing; starting the API alone is insufficient while those paths are absent.

Source record: `docs/runbooks/nonproduction-private-endpoint-cost-pause.md — November 6, 2026, cost-pause worktree`. These internal paths identify provenance; they are not public file links.

## Evidence and project boundaries

The local examples and screenshots in this repository remain separate from the dated hosted incidents above. A new documentation summary does not establish another successful deployment, restore, security scan or business transaction. Follow the repository’s existing validation guide for the commands and limits of the runnable reference.

The practical sequence is: identify the failing boundary, preserve safe correlation evidence, reconcile any uncertain result, apply only the relevant repair and verify the resulting state. A completed local command is not interchangeable with a completed cloud operation.
