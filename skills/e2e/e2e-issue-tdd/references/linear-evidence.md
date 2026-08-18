# Linear device evidence

Use this branch whenever recording, uploading, or commenting on device
validation.

## Reuse and phase rules

Read existing issue comments and attachments first. Reuse valid evidence for the
same revision/build/surface, and post only missing phases.

- During **pre-fix**, record the reproducible bug or missing feature before
  changing production code.
- During **validation resume**, preserve an existing before video. If none
  exists, say
  `Historical before-fix video unavailable; validation resumed after implementation`
  and continue with honest current-state evidence.
- Record **after fix** only after the focused automated checks and final device
  replay are green.

Never downgrade code, reinstall an older build, or undo a fix merely to
manufacture before evidence.

## Recording

Record one tight path from the same precondition through the visible result.
Keep notifications, credentials, OTPs, access tokens, and customer data out of
the frame and filenames. Stop recording promptly so the artifact is small enough
to upload reliably.

For each video retain:

- issue and phase;
- Git revision and dirty-diff identifier;
- app version/build/profile and whether the binary was rebuilt or reused;
- device model, OS, physical/simulator surface, and connection;
- Metro URL/transport state;
- expected and observed result;
- focused automated-check result.

## Upload transaction

The observed Linear signed upload URL expires after 60 seconds. Prepare
everything before requesting one, then execute a single uninterrupted
transaction:

1. prepare the Linear attachment and receive the signed upload URL;
2. immediately `PUT` the raw MP4 with the required content type/headers;
3. finalize the attachment;
4. save the top-level issue comment with the attachment link;
5. read the issue back and confirm both attachment and comment exist.

If the upload URL expires, request a fresh URL and repeat the transaction with
the same local MP4. If recording or upload remains blocked, report the exact
artifact path and failing step without claiming that evidence was posted.

## Comment shape

Use `Before fix` or `After fix` as the first line, followed by concise expected
and observed outcomes, provenance, acceptance-matrix coverage, automated-check
result, and the attachment link. Record pending required surfaces explicitly;
supplemental simulator/emulator evidence does not satisfy a physical-device
requirement.
