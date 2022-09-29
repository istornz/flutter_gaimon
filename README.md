<p align="center">
  <img style="width: 300px; max-width: 300px" src="https://raw.githubusercontent.com/istornz/gaimon/main/.github/images/gaimon.png" />
</p>

# Gaimon

A Flutter plugin to **fully** support Haptic feedback **with custom pattern**.

## 🧐 What is it ?

Gaimon is a **very simple** & **easy to use** plugin to include **Haptic feedback** in your app. It support custom pattern with ```.ahap``` file support.

<p align="center">
  <img style="height: 400px; max-height: 400px" src="https://raw.githubusercontent.com/istornz/gaimon/main/.github/images/preview.jpg" />
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
