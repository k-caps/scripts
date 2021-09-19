# Preparing a linux plex server
1. Install the plex media server app
1. 
```bash
sudo mkdir /var/lib/plexmediaserver/{Anime,TV,Movies}
sudo adduser kobi plex
sudo chown -R plex: /var/lib/plexmediaserver/{Anime,TV,Movies}
sudo find /var/lib/plexmediaserver/{Anime,TV,Movies}-type d -exec chmod 775 {} \;
```
1. Logoff and login
1. **OPTIONAL** If you are copying from another linux install you can use the following command: `sudo rsync -a --info=progress2 /media/plexifier/Elements/plex/plexmediaserver/* /var/lib/plexmediaserver/`, and if you just want to move the metadata, use `plexmediaserver/Library`.  
1. Start your server
