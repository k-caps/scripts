# Preparing a linux plex server
1. Install the plex media server app (sudo `dpkg -i plexmediaserver_<version>.deb`)
1. 
```bash
sudo mkdir /var/lib/plexmediaserver/{Anime,TV,Movies}
sudo adduser kobi plex
sudo chown -R plex: /var/lib/plexmediaserver/{Anime,TV,Movies}
sudo find /var/lib/plexmediaserver/{Anime,TV,Movies} -type d -exec chmod 775 {} \;
```
1. Logoff and login
1. **OPTIONAL**:
If you are copying from another linux install you can use the following command: `sudo rsync -a --info=progress2 --update /media/kobi/Elements/plex/plexmediaserver/* /var/lib/plexmediaserver/`, and if you just want to move the metadata, use `plexmediaserver/Library`.  
1. In case you don't have enough disk space under / for `/var/lib/plexmediaserver` to include your media, store the media on another disk, can be external just mount it on startup with fstab. Make sure it has proper permissions, you won't be able to chown ntfs so you have to mount it under the plex group.
1. To mount a dual boot windows drive as the storage location for the media while keeping the default library location, add this to the fstab and restart: (make sure you use the right device, it might not be `/dev/sda3`)  
`/dev/sda3 /media/kobi/OS ntfs-3g permissions,nls=utf8,umask=000,dmask=027,fmask=137,uid=1000,gid=999,windows_names 0 0`.
1. I find it useful to use symlinks for more transparent management, eg, everything as accessed from /var/lib/plexmediaserver. So: `sudo ln -s /media/kobi/OS/kobi/plex/{Anime,TV,Movies} /var/lib/plexmediaserver`
1. Start your server
