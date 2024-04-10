### Install from the adb host
`adb install <file>.apk`  

```bash
adb pull /storage/self/primary/Download/OpenPods-1.10.apk && adb install OpenPods-1.10.apk && rm OpenPods-1.10.apk
```

## Install from the device itself
This HAS to be under this path for certain Android versions.  
`adb shell pm install /data/local/temp/<file>.apk`

### Install for specific users
Get the users:  
`adb shell pm list users`  
Install the app:
`adb install --user USER_ID PATH_TO_APK`
