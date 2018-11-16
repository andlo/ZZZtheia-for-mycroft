#!/bin/bash
#
# Thos script installs theia-ide for mycroft.
# it needs to be run as root - eg sudo ./install.sh

cd $(dirname "$0")

## Check for freespace and if enough encrease swapfilse size
freespace = $(df . | awk 'NR==2{print $4/1024/1024}')
if [ ${freespace%.*} >= 4 ]; then
    sed -i -e "s/CONF_SWAPSIZE=100/CONF_SWAPSIZE=1024/" /etc/dphys-swapfile
    /etc/init.d/dphys-swapfile stop
    /etc/init.d/dphys-swapfile start
fi

# On Mark_1 the firewall needs to be opend
if [ -f /usr/sbin/ufw ]; then
        sudo ufw allow from any to any port 3000 proto tcp
fi

## install theia-ide as user pi
sudo -i -u pi ./theia_install.sh

## Create and setup service
echo [Unit] > /lib/systemd/system/theia-ide.service
echo Description=Theia IDE >>/lib/systemd/system/theia-ide.service
echo After=multi-user.target >> /lib/systemd/system/theia-ide.service
echo [Service] >> /lib/systemd/system/theia-ide.service
echo Type=simple >> /lib/systemd/system/theia-ide.service
echo ExecStart=$(pwd)/theia_run.sh >>/lib/systemd/system/theia-ide.service
echo Restart=on-abort >>/lib/systemd/system/theia-ide.service
echo User=pi >>/lib/systemd/system/theia-ide.service
echo EnvironmentFile=$(pwd)/theia-ide.env >>/lib/systemd/system/theia-ide.service
echo [Install] >>/lib/systemd/system/theia-ide.service
echo WantedBy=multi-user.target >>/lib/systemd/system/theia-ide.service

chmod 644 /lib/systemd/system/theia-ide.service
systemctl daemon-reload
systemctl enable theia-ide.service
systemctl start theia-ide.service
