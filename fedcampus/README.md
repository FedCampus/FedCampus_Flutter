# fedcampus

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Dart Basics](https://dart.dev/language)
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [《Flutter实战·第二版》(Chinese)](https://book.flutterchina.club/)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Generate pigeon files

In the `lib/pigeons`, there are some pigeon source files as well as the generated files `.g` files. Be careful when you **re-generate** them, as I made some modifications on the generated files.

### Simple way of generating files (using makefile)
Create the pigeon file in that directory.

For windows cmd, powershell: do

```shell
make file=${filename} system=windows
```

For linux:

```shell
make file=${filename}
```
