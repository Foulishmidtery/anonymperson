#!/bin/bash
# ipfs_manager.sh
# Manage IPFS daemon for anonymperson

case "$1" in
  start)
    ipfs daemon --offline &
    echo "IPFS daemon started"
    ;;
  stop)
    killall ipfs 2>/dev/null || true
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
      echo "Usage: $0 share <file_path>"
      exit 1
    fi
    ipfs add "$2"
    ;;
  get)
    if [ -z "$2" ]; then
      echo "Usage: $0 get <ipfs_hash>"
      exit 1
    fi
    ipfs get "$2"
    ;;
  *)
    echo "Usage: $0 {start|stop|status|share <file_path>|get <ipfs_hash>}"
    exit 1
    ;;
esac