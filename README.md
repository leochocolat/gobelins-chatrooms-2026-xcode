# Gobelins Chatrooms 2026

## Overview

This guide gets the Xcode project running on your Mac and your iPhone in about 15 minutes after cloning, with a free Apple ID. Gobelins Chatrooms 2026 is a web app shown inside a native web view, built from one Xcode project for both iOS and macOS.

It covers setup, running on each platform, and the problems people usually hit the first time (Developer Mode, untrusted developer, white screen).

## Requirements

| What | Details |
| --- | --- |
| Mac | A recent macOS version that runs Xcode 16 or later |
| Xcode | 16 or later, from the Mac App Store (the project uses synchronized folders) |
| Apple ID | Any Apple ID works; a paid Apple Developer membership is not required to run locally |
| iPhone (optional) | A cable or the same Wi-Fi as the Mac, to run on a real device |
| Web tooling (optional) | Node.js, if you work on the web app and run its dev server |

A free Apple ID can install the app on your own devices only. Sharing it through TestFlight needs a paid membership.

## Clone and open the project

1. Clone the repository and move into it:

   ```bash
   git clone <repo-url>
   cd <repo-folder>
   ```

2. Open the `.xcodeproj` file by double-clicking it, or run `open *.xcodeproj` from the folder that contains it.
3. Wait for Xcode to finish indexing and resolving Swift packages (progress shows at the top of the window).
4. If Xcode asks whether to trust the project or its package plugins, choose Trust.

> Open question: replace `<repo-url>` and `<repo-folder>` with the real values, and note the path to the `.xcodeproj` if it is not at the repo root.

## Configure signing with your own Apple ID

Every developer signs the app with their own Apple ID, so this step is needed once per machine.

1. In Xcode, open **Xcode → Settings → Accounts**, click **+** and sign in with your Apple ID. A "Personal Team" appears for free accounts.
2. Select the project in the navigator, then the app target, then the **Signing & Capabilities** tab.
3. Keep **Automatically manage signing** checked and pick your team in **Team**.
4. If Xcode reports that the bundle identifier is unavailable, change it to something unique, for example `com.yourname.gobelinschatrooms`.

Keep your team ID and bundle ID out of commits. If the repo includes a `Local.xcconfig.example`, copy it to `Local.xcconfig` (gitignored) and set `DEVELOPMENT_TEAM` and the bundle ID there instead of editing the project. Otherwise, avoid committing the `project.pbxproj` changes these steps create.

```
// Local.xcconfig (not committed)
DEVELOPMENT_TEAM = ABCDE12345
PRODUCT_BUNDLE_IDENTIFIER = com.yourname.gobelinschatrooms
```

Your team ID is shown in Xcode's account details, and in the "Apple Development: …" message on the iPhone (the code in brackets).

## Run on macOS

1. In the toolbar, select the app's scheme, then **My Mac** as the run destination.
2. Press **⌘R** (Product → Run). The app builds and opens as a Mac window.

On macOS the web view needs network permission from the App Sandbox. In **Signing & Capabilities → App Sandbox**, check **Outgoing Connections (Client)**, otherwise the page stays blank. This setting is shared, so commit it.

## Run on iOS

### Simulator

Select an iPhone simulator as the run destination and press **⌘R**. No signing or device setup is needed.

### Physical iPhone

1. Connect the iPhone with a cable, unlock it and tap **Trust This Computer** if asked.
2. Turn on Developer Mode on the iPhone (see [Troubleshooting](#troubleshooting)). The iPhone appears as a destination only once it is enabled.
3. Select the iPhone as the run destination and press **⌘R**.
4. The first launch shows **Untrusted Developer** ("Développeur non approuvé"). Trust your certificate on the iPhone once (see [Troubleshooting](#troubleshooting)), then run again.

After the first run you can unplug the cable: in **Window → Devices and Simulators**, check **Connect via network** to run over Wi-Fi.

With a free Apple ID, the app stops opening after 7 days. Run it again from Xcode to renew it.

## Web content and dev server

The app shows either bundled web files or a page served from a URL. If it loads a local dev server, `localhost` only works on the Mac and in the Simulator.

To use a dev server on a real iPhone:

1. Start the server so it listens on the network, for example `npm run dev -- --host` with Vite.
2. Point the app to your Mac's local IP (System Settings → Wi-Fi → Details), for example `http://192.168.1.23:5173`, keeping the iPhone on the same Wi-Fi.
3. Accept the **Local Network** prompt on the iPhone.
4. For plain `http`, `NSAllowsLocalNetworking` must be `YES` under `NSAppTransportSecurity` in Info.plist.

Keep your personal IP in `Local.xcconfig` or another uncommitted file, not in shared code.

> Open question: document where the app's URL is set and the command that builds the bundled web files.

## Troubleshooting

### iPhone does not appear in Xcode, or Xcode says Developer Mode is disabled

Developer Mode must be on before Xcode can install apps on the iPhone.

1. Connect the iPhone to the Mac once with a cable so the option shows up.
2. On the iPhone, open **Settings → Privacy & Security → Developer Mode** (FR: **Réglages → Confidentialité et sécurité → Mode développeur**) and turn it on.
3. Restart the iPhone when asked. After it restarts, unlock it and tap **Turn On** (« Activer ») to confirm, then enter your passcode.
4. Back in Xcode, select the iPhone again as the destination.

If the Developer Mode option is missing, run the app from Xcode once with the iPhone plugged in; the attempt makes it appear.

### "Untrusted Developer" / « Développeur non approuvé »

The app installs but the iPhone refuses to open it, mentioning "Apple Development: your@email" and a team code. This happens on the first run with a free Apple ID.

1. Open **Settings → General → VPN & Device Management** (FR: **Réglages → Général → VPN et gestion de l'appareil**).
2. Under **Developer App** (« App de développeur »), tap **Apple Development: your@email**.
3. Tap **Trust "Apple Development: …"** (« Faire confiance à… ») and confirm.
4. Open the app again.

You do this once per certificate. If the certificate changes (new Mac, new Apple ID, revoked certificate), the iPhone asks again.

### White screen, Xcode logs `NSURLErrorDomain` code `-1004`

The web view cannot reach the page it should load. Usually the app points to `localhost` while running on a real iPhone. See [Web content and dev server](#web-content-and-dev-server) above. On macOS, check that **Outgoing Connections (Client)** is enabled in App Sandbox.

The log lines "Reading from public effective user settings" and "Could not create a sandbox extension" are harmless and can be ignored.

### App stops opening after a few days

Apps signed with a free Apple ID expire after 7 days. Plug in the iPhone (or use Wi-Fi) and run again from Xcode.

### Signing errors

- **"Failed to register bundle identifier"**: someone already used that bundle ID. Change it to a unique value in `Local.xcconfig` or the target settings.
- **"No account for team"** or **"Signing requires a development team"**: add your Apple ID in Xcode → Settings → Accounts and select your team in Signing & Capabilities.
- **"Maximum number of apps for free development profiles"**: free accounts can have about 3 sideloaded apps per device. Delete an older one from the iPhone and try again.
