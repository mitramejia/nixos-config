# Permission and contacts validation

Read this branch when the issue touches contacts or another native permission.

## Coverage matrix

Test the states the platform can actually represent:

| Platform | State           | Required transition                                      |
| -------- | --------------- | -------------------------------------------------------- |
| iOS      | unset           | prompt, then choose the required result                  |
| iOS      | full            | app starts with full access                              |
| iOS      | limited         | app starts with limited access and selected contacts     |
| iOS      | denied          | app starts denied and follows the Settings/recovery path |
| Android  | unset           | prompt, then grant or deny as required                   |
| Android  | granted         | app starts with the runtime grant                        |
| Android  | denied          | app starts denied without permanent denial               |
| Android  | don't ask again | prompt is suppressed and Settings recovery works         |

Android limited-contact access is `N/A`, not skipped coverage. Keep simulator or
emulator results supplemental when the issue requires physical-device behavior.

## Snapshot and restore

Before mutation, record the package grant plus platform flags. A boolean granted
value is insufficient: Android `USER_SET`/`USER_FIXED` flags affect whether the
prompt returns, while iOS authorization and limited selections affect the next
screen.

Permission mutation can kill or reload the app. After each change:

1. confirm the platform state;
2. re-establish Android reverse transport when applicable;
3. relaunch or deep-link back to the start of the acceptance path;
4. normalize the development client;
5. verify the visible product result.

When the path opens Settings, verify both the system state change and the app's
state after returning. Restore the original grant and flags at cleanup, then
query them again. Cleanup is complete only when the post-cleanup query matches
the original snapshot.

## Temporary Android contacts

Use a unique no-space label such as `MPLT596Fixture` and the helper rather than
assuming `content insert` prints an ID:

```bash
fixture=.agents/skills/e2e/e2e-issue-tdd/scripts/android-contact-fixture.sh

raw_id="$($fixture add \
  --serial emulator-5554 \
  --label MPLT596Fixture \
  --phone +15555550123 | sed -n 's/^raw_contact_id=//p')"

$fixture remove --serial emulator-5554 --raw-id "$raw_id"
$fixture verify-absent --serial emulator-5554 --label MPLT596Fixture
```

The helper snapshots raw-contact IDs before and after insertion, identifies the
single new row, and removes only an explicit raw-contact ID. Add that ID to the
cleanup ledger immediately. If the helper cannot identify exactly one new row,
stop fixture setup and inspect the emulator instead of deleting by label.

For iOS, create/remove contacts through the available supported fixture seam.
Keep limited-contact selections in the cleanup ledger because deleting the
contact alone may not restore the original authorization state.
