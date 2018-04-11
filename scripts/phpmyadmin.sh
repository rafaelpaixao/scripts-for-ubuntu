#!/bin/bash

<<COMMENT
    params:
        --arg1          short description
        --arg2          short description

    Examples:
        bash app.sh --arg1 --arg2 value
COMMENT

while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        if [[ ${#2} != 0 &&  $2 != *"--"* ]]; then
            declare $v="$2"
        else
            declare $v="true"
        fi
   fi
  shift
done

if [ -z ${host+x} ]; then
    host="0.0.0.0"
fi

if [ -z ${port+x} ]; then
    port="4040"
fi
if [ -z ${root_pass+x} ]; then
    root_pass="root"
fi


APP_NAME="PHPMyAdmin"

install () {
    echo "Installing $@..."
    sudo apt-get install -qq --fix-missing --allow-unauthenticated $@ > /dev/null 2>&1
}

addkey () {
    curl -fsSL $@ | sudo apt-key add -
}

addrepo () {
    if ! grep -q "$@" /etc/apt/sources.list; then
        echo "Adding repository $@..."
        sudo add-apt-repository -y $@ > /dev/null 2>&1
        echo "System update..."
        sudo apt-get update > /dev/null 2>&1
    else
        echo "The repository $@  already exists in the source.list!"
    fi
}

echo "------ Script for $APP_NAME..."

echo "Configuring..."
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password "$root_pass
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password "$root_pass
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password "$root_pass
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"

addrepo "ppa:nijel/phpmyadmin"
install phpmyadmin
sudo cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php

echo "Creating service..."
sudo -u root sh <<EOF
sudo echo "
[Unit]
Description=Phpmyadmin Service
After=network.target

[Service]
Type=simple
NonBlocking=true
ExecStart=/usr/bin/php -S $host:$port -t /usr/share/phpmyadmin
ExecStop=killall -9 php
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/phpmyadmin.service
EOF

sudo -u root systemctl daemon-reload
sudo -u root systemctl enable phpmyadmin
sudo -u root systemctl start phpmyadmin

echo "Running on: http://$host:$port"

echo "------ Script for $APP_NAME... Done!"