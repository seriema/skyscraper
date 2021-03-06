#!/bin/bash

LATEST=`wget -q -O - "https://api.github.com/repos/muldjord/skyscraper/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'`

if [ ! -f VERSION ]
then
    echo "VERSION=0.0.0" > VERSION
fi
source VERSION

if [ $LATEST != $VERSION ]
then
    echo "--- Fetching Skyscraper v.$LATEST ---"
    wget -N https://github.com/muldjord/skyscraper/archive/${LATEST}.tar.gz
    if [ $? != 0 ]
    then
	exit
    fi
    echo "--- Unpacking ---"
    tar xvzf ${LATEST}.tar.gz --strip-components 1 --overwrite
    EXITCODE=$?
    if [ $? != 0 ]
    then
	rm VERSION
	echo "--- Failed to unpack Skyscraper v.${LATEST}, exiting with code $EXITCODE ---"
	exit $EXITCODE
    fi
    rm ${LATEST}.tar.gz
    echo "--- Cleaning out old build if one exists ---"
    make clean
    rm .qmake.stash
    qmake
    EXITCODE=$?
    if [ $? != 0 ]
    then
	rm VERSION
	exit $EXITCODE
    fi
    echo "--- Building Skyscraper v.$LATEST ---"
    make -j$(nproc)
    EXITCODE=$?
    if [ $? != 0 ]
    then
	rm VERSION
	echo "--- Failed to built Skyscraper v.${LATEST}, exiting with code $EXITCODE ---"
	exit $EXITCODE
    fi
    echo "--- Installing Skyscraper v.$LATEST ---"
    sudo make install
    EXITCODE=$?
    if [ $? != 0 ]
    then
	rm VERSION
	echo "--- Failed to install Skyscraper v.${LATEST}, exiting with code $EXITCODE ---"
	exit $EXITCODE
    fi
    echo "--- Skyscraper has been updated to v.$LATEST ---"
else
    echo "--- Skyscraper is already the latest version, exiting ---"
    echo "You can force a reinstall by removing the VERSION file by running rm VERSION. Then rerun ./update_skyscraper.sh afterwards."
fi
