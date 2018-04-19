#!/usr/local/bin/bash

# Keeping the short-lived tree size fixed, loop over the long-lived tree
# sizes.

benchmark()
{
    echo "gc_free_space_divisor	kStretchTreeDepth	LongLivedTreeDepth	kArraySize	kMinTreeDepth	kMaxTreeDepth	GC Itertations	Heap Size	Time Elapsed\
" > "$1.unaggregated.tsv"

    kStretchTreeDepth=21
    kLongLivedTreeDepth=16
    kMaxTreeDepth=16

    for ((i=1;i<=5;i++));
    do
        for ((gcFreeSpaceDivisor=1;gcFreeSpaceDivisor<=5;gcFreeSpaceDivisor++));
        do
            echo "Iter $i | gcFreeSpaceDivisor $gcFreeSpaceDivisor | kStretchTreeDepth $kStretchTreeDepth |  kLongLivedTreeDepth $kLongLivedTreeDepth | kMaxTreeDepth $kMaxTreeDepth"
            echo -n "$gcFreeSpaceDivisor	" >> "$1.unaggregated.tsv"
            rtprio 0 ../boehm/benchmark "$kStretchTreeDepth" "$kLongLivedTreeDepth" 500000 4 "$kMaxTreeDepth" "$gcFreeSpaceDivisor" >> "$1.unaggregated.tsv"
        done
    done

    python2 aggregate.py "$1.unaggregated.tsv" > "$1.tsv"
}

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
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
benchmark "result-baseline"
cd ../boehm

# Now for the new version
./install.sh -build-gc
cd "$here"
benchmark "result-writewatch"
