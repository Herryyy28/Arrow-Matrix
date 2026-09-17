@echo off
cd /d "D:\Desktop\Amaze GO!"
call flutter pub get > "%TEMP%\amazego_pub.txt" 2>&1
call flutter test > "%TEMP%\amazego_test.txt" 2>&1
call flutter build apk --debug > "%TEMP%\amazego_build.txt" 2>&1
echo BUILD DONE >> "%TEMP%\amazego_build.txt"
