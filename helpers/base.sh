#!/bin/bash

sfu-install () {
    echo "Installing $@..."
    sudo apt-get install -qq --fix-missing --allow-unauthenticated $@ > /dev/null 2>&1
}

sfu-addkey () {
    curl -fsSL $@ | sudo apt-key add -
}

sfu-addrepo () {
    if ! grep -q "$@" /etc/apt/sources.list; then
        echo "Adding repository $@..."
        sudo add-apt-repository -y $@ > /dev/null 2>&1
        echo "System update..."
        sudo apt-get update > /dev/null 2>&1
    else
        echo "The repository $@  already exists in the source.list!"
    fi
}

export -f sfu-install
export -f sfu-addkey
export -f sfu-addrepo
