import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject var browser: DeepSeekBrowser

    var body: some View {
        VStack(spacing: 0) {
            if let message = browser.errorMessage {
                HStack(spacing: 10) {
                    Image(systemName: "wifi.exclamationmark")
                    Text(message).lineLimit(2)
                    Spacer()
                    Button("Réessayer") { browser.reload() }
                    Button { browser.errorMessage = nil } label: { Image(systemName: "xmark") }
                        .buttonStyle(.plain)
                }
                .padding(10)
                .background(.yellow.opacity(0.18))
            }
            DeepSeekWebView(browser: browser)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct DeepSeekWebView: NSViewRepresentable {
    @ObservedObject var browser: DeepSeekBrowser

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = browser
        view.uiDelegate = browser
        view.setValue(false, forKey: "drawsBackground")
        browser.webView = view
        browser.loadIfNeeded()
        return view
    }

    func updateNSView(_ nsView: WKWebView, context: Context) { }
}
