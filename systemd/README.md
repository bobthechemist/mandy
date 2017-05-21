#Purpose
This directory contains unit files and scripts related to systemd services used by Mandy

#Usage
Place the .service files in `/etc/systemd/system` then run
    sudo systemctl daemon-reload
    sudo systemctl enable speechpipe.service
    sudo systemctl enable shutdownswitch.service


