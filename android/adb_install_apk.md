### Install from the adb host
`adb install <file>.apk`  

```bash
adb pull /storage/self/primary/Download/WhatsApp_Plus_v17.60.apk && adb install WhatsApp_Plus_v17.60.apk && rm WhatsApp_Plus_v17.60.apk
```

## Install from the device itself
Thi HAS to bu under this path for certain Android versions.  
`adb shell pm install /data/local/temp/<file>.apk`
