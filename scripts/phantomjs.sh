#!/bin/bash

<<COMMENT
    params:
        --version           defaults to 2.1.1
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

if [ -z ${version+x} ]; then
    version="2.1.1"
fi
FILENAME=phantomjs-$version-linux-x86_64.tar.bz2

APP_NAME="Phantom JS $version"

echo "------ Script for $APP_NAME..."
echo "Downloading..."
sudo wget -q https://bitbucket.org/ariya/phantomjs/downloads/$FILENAME > /dev/null 2>&1
echo "Installing..."
sudo tar xvjf $FILENAME -C /usr/local/share/ > /dev/null 2>&1
sudo ln -s /usr/local/share/$FILENAME/bin/phantomjs /usr/local/bin/ > /dev/null 2>&1
echo "Cleaning..."
sudo rm $FILENAME
echo "------ Script for $APP_NAME... Done!"