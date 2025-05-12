#!/bin/bash

# IPFS manager script for anonymperson

case "$1" in
    start)
        ipfs daemon --enable-pubsub &
        echo "IPFS daemon started"
        ;;
    stop)
        killall ipfs
        echo "IPFS daemon stopped"
        ;;
    status)
        if pgrep ipfs > /dev/null; then
            echo "IPFS daemon is running"
        else
            echo "IPFS daemon is not running"
        fi
        ;;
    share)
        if [ -z "$2" ]; then
            echo "Usage: ipfs_manager.sh share <file_path>"
            exit 1
        fi
        HASH=$(ipfs add -r "$2" | tail -n1 | awk '{print $2}')
        echo "File shared on IPFS with hash: $HASH"
        ;;
    get)
        if [ -z "$2" ]; then
            echo "Usage: ipfs_manager.sh get <ipfs_hash>"
            exit 1
        fi
        ipfs get "$2" -o /home/wkali/ipfs_downloads/
        echo "File downloaded to /home/wkali/ipfs_downloads/"
        ;;
    *)
        echo "Usage: $0 {start|stop|status|share <file_path>|get <ipfs_hash>}"
        exit 1
        ;;
esac

exit 0
