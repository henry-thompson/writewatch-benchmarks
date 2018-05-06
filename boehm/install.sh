#!/usr/local/bin/bash

# This script builds and installs the Boehm GC from source.
# It will `git pull` the Boehm source from GitHub if not
# present in ./bdwgc, and correctly configures the source
# for build.

# Usage: ./install-gc.sh [-clean] [-original] [-force-gengc] [-buffer N] [-build-gc]

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ "$1" = "-clean" ]; then
    rm -rf bdwgc
fi

echo "=== CONFIGURING GC INSTALLATION ==="

if [ ! -d "./bdwgc" ]; then
   git clone https://github.com/henry-thompson/bdwgc
   cd bdwgc
   ./autogen.sh
   ./configure
else
   cd bdwgc
   git reset HEAD --hard
   git clean -f
   git pull
   git fetch
fi

if [ "$1" = '-original' ]; then
    shift
    git checkout master
    echo "GC Selected: ORIGINAL"
    git reset HEAD --hard
    git clean -f
else
    git checkout freebsd-writewatch-vdb
    echo "GC Selected: mwritten"
    git reset HEAD --hard
    git clean -f
    if [ "$1" = "-buffer" ]; then
      shift
      # This is a REALLY bad way of setting the buffer length, but will do for
      # now until I figure out how that MAKEFILE works...
      sed -i '' 's/# define GC_FBSD_MWW_BUF_LEN.*$/# define GC_FBSD_MWW_BUF_LEN '"$1"'/' ./os_dep.c
      echo "Buffer size: $1"
      shift
    else
      echo "Using default buffer size"
    fi
fi

if [ "$1" = "-force-gengc" ]; then
    shift
    # Line 1297 is the end if the GC_init() function. Yes, we make it call
    # GC_enable_incremental() which forces all users to use generational GC.
    # Its not clean but it works...
    sed -i "" "1297i\\
    GC_enable_incremental();" misc.c
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
