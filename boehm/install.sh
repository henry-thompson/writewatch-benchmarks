#!/usr/local/bin/bash

# This script builds and installs the Boehm GC from source.
# It will `git pull` the Boehm source from GitHub if not
# present in ./bdwgc, and correctly configures the source
# for build.

# Usage: ./install-gc.sh [-clean] [-original] [-buffer N] [-build-gc]

if [ "$1" = "-clean" ]; then
    rm -rf bdwgc
fi

echo "=== CONFIGURING GC INSTALLATION ==="

if [ ! -d "./bdwgc" ]; then
   git clone https://github.com/henry-thompson/bdwgc
   cd bdwgc
else
   cd bdwgc
   git pull
   git fetch
fi

git reset HEAD --hard
git clean -f

if [ "$1" = '-original' ]; then
    shift
    git checkout master
    echo "GC Selected: ORIGINAL"
else
    git checkout freebsd-writewatch-vdb
    echo "GC Selected: WRITEWATCH"
    if [ "$1" = "-buffer" ]; then
      shift
      # This is a REALLY bad way of setting the buffer length, but will do for
      # now until I figure out how that MAKEFILE works...
      sed -i '' 's/# define GC_FBSD_MWW_BUF_LEN.*$/# define GC_FBSD_MWW_BUF_LEN '"$1"'/' ./os_dep.c
      echo "Buffer size: $1"
      shift
    else
      echo "Default buffer: $1"
    fi
fi

./autogen.sh
./configure --disable-threads

if [ "$1" = "-build-gc" ]; then
    shift
    echo "=== BUILDING GC ==="
    make
    make check
fi

echo "=== INSTALLING GC ==="
make install
