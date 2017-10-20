#!/bin/sh
echo "started" >> /tmp/log.txt
TEMPDOWNLOAD=/Users/vagrant/Library/Caches/VisualStudio/7.0/TempDownload
MYPWD=$(pwd)

echo "cleaning temp" >> /tmp/log.txt
cd $TEMPDOWNLOAD
if [ $? != 0 ]; then
    echo "There is no temp directory yet."
    echo "no temp" >> /tmp/log.txt
else
    echo "yes temp" >> /tmp/log.txt
    echo "Removing all files from $TEMPDOWNLOAD..."
    yes | rm *
    # if [ $? != 0 ]; then
    #     echo "oops" >> /tmp/log.txt
    # fi
fi
echo "updater" >> /tmp/log.txt
echo "Running the downloader applescript..."
cd $MYPWD    
sudo -H -u vagrant bash -c 'osascript /tmp/vs4mac-autoupdate/download_updates.applescript'
if [ $? != 0 ]; then
    echo "The applescript has failed. Exiting."
    exit 1
fi
cd $TEMPDOWNLOAD