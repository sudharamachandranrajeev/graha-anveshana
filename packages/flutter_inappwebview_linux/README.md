# flutter\_inappwebview\_linux

The Linux WPE WebKit implementation of [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview).

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `flutter_inappwebview`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.
## Graha Anveshana's copy (from Bhojana)

A copy of `flutter_inappwebview_linux` 0.1.0-beta.1 (Apache-2.0, see
LICENSE), used through `dependency_overrides` in the app's pubspec. One
change: `linux/CMakeLists.txt` needs libwpe (wpe-1.0) only for the legacy
WPEBackend-FDO path, because WPE WebKit 2.52 and later with WPEPlatform
(Arch, Fedora) ship without it. The example app is left out. Drop this
copy once upstream makes libwpe optional.
