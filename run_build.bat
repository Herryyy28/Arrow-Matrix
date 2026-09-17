@echo off
cd /d "D:\Desktop\Amaze GO!"
echo === FLUTTER ANALYZE ===
call flutter analyze > analyze.log 2>&1
echo === FLUTTER TEST ===
call flutter test > test.log 2>&1
echo === FLUTTER BUILD DEBUG APK ===
call flutter build apk --debug > build_debug.log 2>&1
echo === FLUTTER BUILD RELEASE APK ===
call flutter build apk --release > build_release.log 2>&1
echo === FLUTTER BUILD APPBUNDLE ===
call flutter build appbundle --release > build_bundle.log 2>&1
echo === FLUTTER DEVICES ===
call flutter devices > devices.log 2>&1
echo === DONE ===
