#!/bin/bash

<<COMMENT
    params:
        --user              new user, defaults to root
        --pass              pass for new user, defaults to root
        --db                database's name, defaults to example
        --root_user         root user, defaults to root
        --root_pass         pass of root user, defaults to root

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

if [ -z ${user+x} ]; then
    user="root"
fi

if [ -z ${pass+x} ]; then
    user="root"
fi

if [ -z ${root_user+x} ]; then
    user="root"
fi

if [ -z ${root_pass+x} ]; then
    user="root"
fi

if [ -z ${db+x} ]; then
    user="example"
fi

APP_NAME="MySQL Server"

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
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password "$root
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password "$root
install mysql-server
echo "Creating database $db with user $user and pass $pass..."
mysql -u$root_user -p$root_pass -e "CREATE DATABASE "$db > /dev/null 2>&1
mysql -u$root_user -p$root -e "grant all privileges on "$db".* to '"$user"'@'localhost' identified by '"$pass"'" > /dev/null 2>&1

echo "------ Script for $APP_NAME... Done!"