import SwiftUI

@main
struct DeepSeekApp: App {
    @StateObject private var browser = DeepSeekBrowser()

    var body: some Scene {
        WindowGroup {
            ContentView(browser: browser)
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(after: .appInfo) {
                Button("Déconnexion") { browser.signOut() }
                    .keyboardShortcut("l", modifiers: [.command, .shift])
                Divider()
                Button("Recharger") { browser.reload() }
                    .keyboardShortcut("r", modifiers: .command)
            }
        }
    }
}
