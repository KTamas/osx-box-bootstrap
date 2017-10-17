#!/bin/sh

TEMPDOWNLOAD=/Users/vagrant/Library/Caches/VisualStudio/7.0/TempDownload
MYPWD=$(pwd)

count_files () {
    cd $TEMPDOWNLOAD
    numfiles=$(ls | wc -l)
    echo $numfiles
}

install_updates () {
    cd $TEMPDOWNLOAD
    for f in *.pkg; do
        [ -f "$f" ] || break
        echo "Installing $f"
        /usr/sbin/installer -pkg $f -target /
        if [ $? != 0 ]; then
            echo "Failed to install: $f"
            exit 1
        else
            echo "Successfully installed: $f"
            rm $f
        fi
    done

    for f in *.mpack; do
        [ -f "$f" ] || break
        echo "Installing $f"
        yes | "/Applications/Visual Studio.app/Contents/MacOS/vstool" setup i $f
        if [ $? != 0 ]; then
            echo "Failed to install: $f"
            exit 1
        else
            echo "Successfully installed: $f"
            rm $f
        fi
    done

    for f in *.dmg; do
        [ -f "$f" ] || break
        echo "Installing $f"
        hdiutil attach $f -mountpoint /Volumes/tmp
        if [ $? != 0 ]; then
            echo "Failed to mount: $f"
            exit 1
        fi
        cd /Volumes/tmp
        cp -Rf *.app /Applications
        if [ $? != 0 ]; then
            echo "Failed to copy from $f"
            exit 1
        fi
        cd $TEMPDOWNLOAD
        sleep 2
        hdiutil detach /Volumes/tmp
        if [ $? != 0 ]; then
            echo "Failed to unmount: $f"
            exit 1
        fi
        echo "Successfully installed: $f"
        rm $f
    done

    # hardcoded for now
    if [ -f VisualStudioUpdate.app.zip ]; then
        echo "Installing VSUpdate"
        /usr/bin/unzip VisualStudioUpdate.app.zip
        if [ $? != 0 ]; then
            echo "Failed to unzip VisualStudioUpdate.app.zip"
            exit 1
        fi
        cp -Rf "Visual Studio Update.app" "/Applications/Visual Studio.app/Contents/MacOS"
        rm -rf "./Visual Studio Update.app"
        rm VisualStudioUpdate.app.zip
        echo "Successfully installed: VisualStudioUpdate.app.zip"
    fi

    echo '-----------------------------------------------------------------'
    
    num_files=$(count_files)
    if [[ $num_files -gt 2 ]]; then
        echo "There are unknown files in the download directory, please investigate. List of files:"
        ls -l
        exit 1
    fi
}

clean_tempdownload () {
    cd $TEMPDOWNLOAD
    if [ $? != 0 ]; then
        echo "There is no temp directory yet."
    else
        echo "Removing all files from $TEMPDOWNLOAD..."
        yes | rm *
    fi
}

download_updates () {
    echo "Running the downloader applescript..."
    cd $MYPWD    
    sudo -H -u vagrant bash -c 'osascript download_updates.applescript'
    if [ $? != 0 ]; then
        echo "The applescript has failed. Exiting."
        exit 1
    fi
    cd $TEMPDOWNLOAD
}

# ----- Main -----

# This needs to be ran as root
if [ $EUID != 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

echo "Starting..."

clean_tempdownload
download_updates

num_files=$(count_files)
while [ $num_files -gt 2 ]; do
    install_updates
    clean_tempdownload
    download_updates
    num_files=$(count_files)
done
echo "There are no more updates."