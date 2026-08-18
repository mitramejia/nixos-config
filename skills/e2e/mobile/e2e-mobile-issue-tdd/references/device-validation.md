# Device validation

Use this branch for every manual Appium acceptance run.

Use the issue's requested surface. Prefer a compatible USB-connected physical
device when physical behavior is required or available. Treat simulator or
emulator validation as fallback/supplemental coverage and name that surface in
the acceptance matrix. Choose iOS simulator versus physical device explicitly.

## Preflight and provenance

Run the read-only helper from the repository root:

```bash
.agents/skills/e2e/mobile/e2e-mobile-issue-tdd/scripts/device-preflight.sh \
  --platform android \
  --device emulator-5554 \
  --app-id app.comun.mobile.debug \
  --metro-url http://127.0.0.1:8081 \
  --artifact /absolute/path/to/app-debug.apk
```

Use `--platform ios` with the simulator UDID and bundle ID for iOS. Omit
`--artifact` only when intentionally reusing an installed binary. Preserve the
output with test notes; it identifies Git revision/diff, device/OS, installed
app version/build, Metro reachability, Android reverse state, and artifact hash.

An installed app is not proof of current source. Record whether it was freshly
built, freshly installed, or reused, along with the build profile and install
time when the platform exposes it.

## Normalize the development client

Before the product journey, clear whichever development surface is visible:

1. Complete or dismiss development-client onboarding.
2. Close the developer menu.
3. From the launcher, open the current Metro project.
4. Recover a load-error screen only after proving Metro and device transport.
5. Complete test-account passcode/login state using the repository fixture.

Capture a screenshot and hierarchy after normalization. Product validation
starts only when a product-owned screen is visible.

For an OTP fixture, reuse the existing E2E Twilio helper. Fetch and enter the
OTP within one secure orchestration call so its value is neither printed nor
copied into the transcript.

## Android transport and Appium stability

Check and, when missing, reapply:

```bash
adb -s <serial> reverse tcp:8081 tcp:8081
```

Recheck reverse state after session creation, force-stop, relaunch, or a Metro
load error. A working host Metro port does not prove emulator transport.

For local UiAutomator2 sessions that use screenshots, keep the MJPEG stream
light and reduce idle blocking:

```json
{
  "appium:settings[waitForIdleTimeout]": 0,
  "appium:settings[mjpegServerFramerate]": 1,
  "appium:settings[mjpegScalingFactor]": 50
}
```

If `DeadObjectException`, instrumentation loss, or a dead UiAutomation binder
appears, save server log and logcat, restore Metro transport, and reattach once.
A second occurrence is a harness failure to route through
`e2e-mobile-test-troubleshooter`, not a product failure.

## System-owned UI

Use stable native selectors whenever the system UI appears in the hierarchy. For
an iOS system contacts sheet that is visible in a screenshot but absent from the
Appium hierarchy, a coordinate tap is allowed only when all of these are true:

- the screenshot proves the target and current window size;
- the coordinate is computed for that exact screenshot/device;
- a post-action screenshot proves the expected transition.

Coordinates do not transfer across devices, orientations, or subsequent system
screens.

## Failure classification

Before changing app code, label the failed step:

- **App:** the current build reached the required product state and visibly
  produced the wrong result.
- **Environment:** Metro, reverse/USB transport, credentials, debug binary, or
  OS state prevented the journey.
- **Harness:** Appium, UiAutomator2/XCUITest, selector transport, or recording
  failed independently of the visible customer outcome.

Capture screenshot, hierarchy, Appium server log, and platform log before
recovery. One successful command does not override contradictory visible state.
