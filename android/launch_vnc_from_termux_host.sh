#!/bin/bash
distro="andronix-fs"
cat >> $distro/kobivnc << EOF
#!/bin/bash
sudo -u kobi vncserver-start
EOF
