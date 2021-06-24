#!/bin/bash
# mobilertc precompile process to remove libc++_shared.so
# ./node_modules/react-native-zoom-us-bridge/scripts/mobilertc-precompile.sh

echo "Removing libc++_shared.so from mobilertc.aar"

# check if mobilertc.aar is present, end if not
FILE=./android/mobilertc/mobilertc.aar
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "Abort $FILE does not exist."
    exit 1
fi

# first lets go to the right folder
cd android && cd mobilertc

# unzip the file
echo "Unzip original mobilertc.aar"
unzip mobilertc.aar -d tempMobileRTCFolder
cd tempMobileRTCFolder

# remove the files
echo "Remove libc++_shared.so"
rm ./jni/arm64-v8a/libc++_shared.so
rm ./jni/armeabi-v7a/libc++_shared.so
rm ./jni/x86/libc++_shared.so
rm ./jni/x86_64/libc++_shared.so

# zip new file
echo "Zip new mobilertcNew.aar"
zip -r ../mobilertcNew.aar *
cd ..

# backup original file, replace mobilertc.aar
echo "Backup original lib and copy new lib"
mv mobilertc.aar mobilertcOriginal.aar
mv mobilertcNew.aar mobilertc.aar

# remove temp unzip folder
echo "Clean up"
rm -rf tempMobileRTCFolder
cd .. && cd ..

echo "Done"
exit 0