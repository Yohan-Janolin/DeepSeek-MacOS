import AppKit
import Combine
import WebKit

@MainActor
final class DeepSeekBrowser: NSObject, ObservableObject {
    @Published var errorMessage: String?
    @Published private(set) var canGoBack = false
    @Published private(set) var canGoForward = false
    weak var webView: WKWebView?
    private var loaded = false

    private let homeURL = URL(string: "https://chat.deepseek.com")!

    func loadIfNeeded() {
        guard !loaded else { return }
        loaded = true
        webView?.load(URLRequest(url: homeURL))
    }

    func reload() { errorMessage = nil; webView?.reload() }
    func goBack() { webView?.goBack() }
    func goForward() { webView?.goForward() }
    func goHome() { errorMessage = nil; webView?.load(URLRequest(url: homeURL)) }

    private func updateNavigationState() {
        canGoBack = webView?.canGoBack ?? false
        canGoForward = webView?.canGoForward ?? false
    }

    private func isDeepSeekURL(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }
        return host == "deepseek.com" || host.hasSuffix(".deepseek.com")
    }

    private func openOutsideAppIfNeeded(_ action: WKNavigationAction) -> Bool {
        guard action.navigationType == .linkActivated,
              let url = action.request.url,
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              !isDeepSeekURL(url) else { return false }
        NSWorkspace.shared.open(url)
        return true
    }

    func signOut() {
        let domain = "deepseek.com"
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { [weak self] records in
            let matching = records.filter { $0.displayName == domain || $0.displayName.hasSuffix("." + domain) }
            WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: matching) {
                Task { @MainActor in
                    self?.webView?.load(URLRequest(url: URL(string: "https://chat.deepseek.com")!))
                }
            }
        }
    }
}

extension DeepSeekBrowser: WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        show(error)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        show(error)
    }
    private func show(_ error: Error) {
        let nsError = error as NSError
        guard nsError.code != NSURLErrorCancelled else { return }
        errorMessage = "Impossible de charger DeepSeek. Vérifiez votre connexion, puis réessayez. (\(error.localizedDescription))"
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        errorMessage = nil
        updateNavigationState()
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) { updateNavigationState() }

    // Les liens DeepSeek restent dans l'app. Les liens des sites tiers partent dans le navigateur par défaut.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil else { return nil }
        if !openOutsideAppIfNeeded(navigationAction),
           let url = navigationAction.request.url,
           let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) {
            webView.load(navigationAction.request)
        }
        return nil
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if openOutsideAppIfNeeded(navigationAction) {
            decisionHandler(.cancel)
            return
        }
        guard let scheme = navigationAction.request.url?.scheme?.lowercased() else { decisionHandler(.allow); return }
        if ["http", "https", "about", "blob", "data"].contains(scheme) { decisionHandler(.allow) }
        else {
            // Les liens externes usuels sont ouverts par macOS; les schémas inconnus sont ignorés.
            if let url = navigationAction.request.url, ["mailto", "tel"].contains(scheme) { NSWorkspace.shared.open(url) }
            decisionHandler(.cancel)
        }
    }

    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse,
                 didBecome download: WKDownload) { download.delegate = self }
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction,
                 didBecome download: WKDownload) { download.delegate = self }
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse,
                 suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = suggestedFilename
        panel.canCreateDirectories = true
        panel.begin { result in completionHandler(result == .OK ? panel.url : nil) }
    }
    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) { show(error) }
}
