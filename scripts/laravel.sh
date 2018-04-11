#!/bin/bash

APP_NAME="Laravel"

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

if [ -x "$(command -v laravel)" ]; then
    echo "Laravel is already installed!"
    exit 1
fi

install curl
install unzip
install python-software-properties
addrepo "ppa:ondrej/php"
echo "System update..."
install php7.2-cli
install php7.2-mysql
install php7.2-curl
install php7.2-json
install php7.2-cgi
install php7.2-xsl
install php7.2-mbstring
install php7.2-xml
install php7.2-gd
install php7.2-gettext
install php7.2-zip
install php7.2-cli
install php7.2-cgi
install php7.2-fpm

echo "Installing Composer..."
curl -sS https://getcomposer.org/installer -o composer-setup.php > /dev/null 2>&1
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1
rm composer-setup.php

echo "Installing Laravel..."
sudo chown -R $USER $HOME/.composer > /dev/null 2>&1
composer global require "laravel/installer" > /dev/null 2>&1

sudo echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc
. ~/.bashrc

echo "------ Script for $APP_NAME... Done!"



