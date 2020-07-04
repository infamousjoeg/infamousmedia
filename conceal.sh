#!/bin/bash
set -eo pipefail

###########################################################
#####  Maintainer: Joe Garcia <joe@joe-garcia.com>    #####
###########################################################
#####  Description: No footprint script for adding    #####
#####   secrets to MacOS Keychain Access for use with #####
#####   Summon (https://cyberark.github.io/summon)    #####
###########################################################

# main is the main function of the script
main () {
    detect_os
    install_brew
    install_conceal
    if [[ $1 == "remove" ]]; then
        remove_secret
    else
        conceal_secret
    fi
    remove_conceal
    remove_brew
}

# detect_os exits if an OS other than MacOS is found
detect_os () {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "Only MacOS supported. Exiting..."
        exit 1
    fi
    echo "MacOS detected."
}

# install_brew checks for Homebrew and installs it, if missing
# https://brew.sh
install_brew () {
    if [ -z "$(command -v brew)" ]; then
        # Installing Homebrew
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh
        # Setting "Homebrew Installed?" flag to False, so it
        # WILL be removed later
        BREWSKI=False
        echo "Temporarily installed Homebrew (https://brew.sh)"
    else
        # Setting "Homebrew Installed?" flag to TRUE, so it
        # IS NOT removed later
        BREWSKI=True
        echo "Homebrew detected"
    fi
}

# install_conceal checks for conceal and installs it, if missing
# https://github.com/infamousjoeg/go-conceal
install_conceal () {
    if [ -z "$(command -v conceal)" ]; then
        # Installing Conceal via Homebrew
        brew tap infamousjoeg/tap
        brew install conceal
        # Setting "Conceal Installed?" flag to FALSE, so it
        # WILL be removed later
        CONCEALSKI=False
        echo "Temporarily installed Conceal (https://github.com/infamousjoeg/go-conceal)"
    else
        # Setting "Conceal Installed?" flag to TRUE, so it
        # IS NOT removed later
        CONCEALSKI=TRUE
        echo "Conceal detected"
    fi
}

conceal_secret () {
    echo "Attempting to store value in MacOS Keychain..."
    echo -e "\nCopy & paste your Plex claim token below\n"
    conceal -a plex/claimtoken
}

remove_secret () {
    echo "Removing plex/claimtoken from MacOS Keychain"
    conceal -r plex/claimtoken
}

# remove_conceal will remove conceal if it was not previously
# installed
remove_conceal () {
    if [ $CONCEALSKI == True ]; then
        brew uninstall conceal
    fi
    echo "Conceal was not previously installed => Removed"
}

# remove_brew will remove Homebrew if it was not previously
# installed
remove_brew () {
    if [ $BREWSKI == True ]; then
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall
    fi
    echo "Homebrew was not previously installed => Removed"
}

# Start main function and pass all arguments
main "$@"