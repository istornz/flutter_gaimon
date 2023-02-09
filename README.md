<p align="center">
  <img src="https://github.com/istornz/gaimon/blob/main/images/gaimon.jpg?raw=true" />
</p>

<div align="center" style="display: flex;align-items: center;justify-content: center;">
  <a href="https://pub.dev/packages/gaimon"><img src="https://img.shields.io/pub/points/gaimon?style=for-the-badge" style="margin-right: 10px" /></a>
  <a href="https://pub.dev/packages/gaimon"><img src="https://img.shields.io/pub/likes/gaimon?style=for-the-badge" style="margin-right: 10px" /></a>
  <a href="https://pub.dev/packages/gaimon"><img src="https://img.shields.io/pub/popularity/gaimon?style=for-the-badge" style="margin-right: 10px" /></a>
  <a href="https://pub.dev/packages/gaimon"><img src="https://img.shields.io/pub/v/gaimon?style=for-the-badge" style="margin-right: 10px" /></a>
  <a href="https://github.com/istornz/gaimon"><img src="https://img.shields.io/github/stars/istornz/gaimon?style=for-the-badge" /></a>
</div>
<br />

## 🧐 What is it ?

Gaimon is a **very simple** & **easy to use** plugin to include **Haptic feedback** in your app. It support custom pattern with ```.ahap``` file support.
<br />

<p align="center">
  <img style="height: 500px; max-height: 500px" src="https://raw.githubusercontent.com/istornz/gaimon/main/images/preview.jpg" />
</p>

## 👻 Getting started

- Import the plugin.

```dart
import 'package:gaimon/gaimon.dart';
```

- Trigger haptic 📳.

```dart
Gaimon.selection();
Gaimon.success();
Gaimon.error();
// [...]
```

Quite simple right ? 😎

## 📘 Documentation

| Name | Description | Android  | iOS |
| ---- | ----------- | -------- | --- |
| ```.canSupportsHaptic()``` | Check if haptic are supported or not | ✅ | ✅ |
| ```.selection()``` | Use it on a tap event | ✅ | ✅ |
| ```.error()``` | Use it when an error occur | ✅ | ✅ |
| ```.success()``` | Use it when a successful event occur | ✅ | ✅ |
| ```.warning()``` | Use it when a warning event occur | ✅ | ✅ |
| ```.heavy()``` | Huge feedback | ✅ | ✅ |
| ```.medium()``` | Medium feedback | ✅ | ✅ |
| ```.light()``` | Light feedback | ✅ | ✅ |
| ```.rigid()``` | A huge but speed feedback | ✅ | ✅ |
| ```.soft()``` | A medium but speed feedback | ✅ | ✅ |
| ```.pattern(String data)``` | Read a custom ```.ahap``` file (you can use [Captain AHAP](https://ahap.fancypixel.it/) to generate file) | ⛔️  | ✅ |

## 🎯 Roadmap

- [ ] Support pattern for Android (send ```.ahap``` file & convert it to waveform).
- [ ] Support audio file to haptic feedback (generate correct feedback for audio file).

## 👥 Contributions

Contributions are welcome. Contribute by creating a PR or create an issue 🎉.