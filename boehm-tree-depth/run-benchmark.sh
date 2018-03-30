#!/usr/local/bin/bash

# Keeping the short-lived tree size fixed, loop over the long-lived tree
# sizes.

benchmark()
{
    echo "kStretchTreeDepth	LongLivedTreeDepth	kArraySize	kMinTreeDepth	kMaxTreeDepth	GC Itertations	Heap Size	Time Elapsed\
" > "$1.unaggregated.tsv"

    for ((i=1;i<=30;i++));
    do
        for ((kLongLivedTreeDepth=16;kLongLivedTreeDepth<=25;kLongLivedTreeDepth++));
        do
            echo "Iter $i: kLongLivedTreeDepth=$kLongLivedTreeDepth"
            rtprio 0 ../boehm/benchmark 19 "$kLongLivedTreeDepth" >> "$1.unaggregated.tsv"
        done
    done

    python2 aggregate.py "$1.unaggregated.tsv" > "$1.tsv"
}

here="$PWD"
cd ../boehm

# Make sure benchmarker is built
./build.sh

# Build and install the original GC
./install.sh -original -build-gc
cd "$here"
benchmark "result-baseline"

# Now for the new version
./install.sh -buffer 16 -build-gc
cd "$here"
benchmark "result-writewatch"