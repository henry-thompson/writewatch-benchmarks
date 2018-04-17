#!/usr/local/bin/bash

# Keeping the short-lived tree size fixed, loop over the long-lived tree
# sizes.

# Options:
#    -short-lived-tree N             Specifies use short-lived tree depth N

benchmark()
{
    echo "kStretchTreeDepth	LongLivedTreeDepth	kArraySize	kMinTreeDepth	kMaxTreeDepth	GC Itertations	Heap Size	Time Elapsed\
" > "$1.unaggregated.tsv"

    for ((i=1;i<=30;i++));
    do
        for ((kLongLivedTreeDepth=16;kLongLivedTreeDepth<=25;kLongLivedTreeDepth++));
        do
            echo "Iter $i | kLongLivedTreeDepth $kLongLivedTreeDepth | (kShortLivedTreeDepth $2)"
            rtprio 0 ../boehm/benchmark "$2" "$kLongLivedTreeDepth" >> "$1.unaggregated.tsv"
        done
    done

    python2 aggregate.py "$1.unaggregated.tsv" > "$1.tsv"
}

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

shortLivedTreeDepth=21
if [ "$1" = "-short-lived-tree" ]; then
    shortLivedTreeDepth="$2"
fi

here="$PWD"
cd ../boehm
chmod +x ./build.sh
chmod +x ./install.sh

# Make sure benchmarker is built
./build.sh

# Build and install the original GC
./install.sh -original -build-gc
cd "$here"
benchmark "result-baseline" "$shortLivedTreeDepth"
cd ../boehm

# Now for the new version
./install.sh -buffer 16 -build-gc
cd "$here"
benchmark "result-writewatch" "$shortLivedTreeDepth"
