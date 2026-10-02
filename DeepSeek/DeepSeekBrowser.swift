import AppKit
import Combine
import WebKit

@MainActor
final class DeepSeekBrowser: NSObject, ObservableObject {
    @Published var errorMessage: String?
    weak var webView: WKWebView?
    private var loaded = false
    private var downloads: [ObjectIdentifier: URL] = [:]

    func loadIfNeeded() {
        guard !loaded, let url = URL(string: "https://chat.deepseek.com") else { return }
        loaded = true
        webView?.load(URLRequest(url: url))
    }

    func reload() { errorMessage = nil; webView?.reload() }

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
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { errorMessage = nil }

    // Les fenêtres demandées par le site (target=_blank, OAuth, etc.) restent dans la fenêtre native.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil else { return nil }
        if let url = navigationAction.request.url, let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) {
            webView.load(navigationAction.request)
        }
        return nil
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
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
