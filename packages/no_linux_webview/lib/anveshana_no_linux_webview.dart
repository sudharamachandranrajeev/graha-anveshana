/// Graha Anveshana's Linux "implementation" of flutter_inappwebview: it
/// registers nothing, so hasWebView is false and pages that need a browser
/// open in the system browser.
class NoLinuxWebView {
  static void registerWith() {}
}
