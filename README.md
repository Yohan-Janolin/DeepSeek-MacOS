# DeepSeek for macOS

A small native SwiftUI app that displays [chat.deepseek.com](https://chat.deepseek.com) in a macOS window using `WKWebView`, without an address bar.

## Requirements

- A Mac running **macOS 14 Sonoma or later**.
- **Xcode 15 or later**.
- An Internet connection to access DeepSeek.

## Open and build the project

1. Unzip `DeepSeek-Xcode.zip` into a folder of your choice.
2. In the `DeepSeek` folder, open **`DeepSeek.xcodeproj`** in Xcode.
3. In the Xcode toolbar, select the **DeepSeek** scheme and the **My Mac** destination.
4. To build without launching the app, choose **Product > Build** or press **⌘B**.
5. To build and launch the app, choose **Product > Run** or press **⌘R**.

The first build may take a little while. Indexing or App Intents warnings that do not prevent Xcode from reporting **Build Succeeded** can be ignored.

## Find the built app

After a successful build, Xcode creates `DeepSeek.app` in the `Build/Products/Debug` folder inside its Derived Data directory. To reveal it in Finder:

1. Open the Project navigator in Xcode with **⌘1**.
2. Expand **Products** at the bottom of the file list.
3. Right-click **DeepSeek.app** and choose **Show in Finder**.

If that command is unavailable, choose **Product > Show Build Folder in Finder**, then open `Products/Debug/DeepSeek.app`.

## Create an archive for distribution

To prepare a distribution archive, select the **Any Mac (Apple Silicon, Intel)** destination, then choose **Product > Archive**. Xcode opens Organizer, where you can export or sign the app. Distributing the app to others may require an Apple Developer ID signature and notarization.

## Using the app

- Your login session is kept between launches using persistent WebKit storage (`WKWebsiteDataStore.default()`).
- **DeepSeek > Sign Out** clears WebKit data associated with `deepseek.com` (shortcut **⇧⌘L**).
- DeepSeek pages stay in the app. Links to other websites open in your default browser.
- The navigation bar lets you go back, go forward, reload, or return to DeepSeek.
- Downloads use the macOS save dialog.
- The standard macOS shortcuts **⌘W** and **⌘Q** close the window and quit the app.

The provided bundle identifier is `com.example.DeepSeek`. You can change it under **Target DeepSeek > Signing & Capabilities** before signing or distributing your own build.

## App icon

The app icon uses the official DeepSeek website favicon SVG: <https://fe-static.deepseek.com/chat/favicon.svg>.
