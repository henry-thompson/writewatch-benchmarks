

# Keeping the short-lived tree size fixed, loop over the long-lived tree
# sizes.

benchmark()
{
    echo "kStretchTreeDepth	LongLivedTreeDepth	kArraySize	kMinTreeDepth	kMaxTreeDepth	GC Itertations	Heap Size	Time Elapsed\
" > "unaggregated.temp"

    for ((i=1;i<=30;i++));
    do
        for ((kLongLivedTreeDepth=16;kLongLivedTreeDepth<=25;kLongLivedTreeDepth++));
        do
            echo "Iter $i: kLongLivedTreeDepth=$kLongLivedTreeDepth"
            rtprio 0 ../boehm/benchmark 19 "$kLongLivedTreeDepth" >> "$1"
        done
    done

    python2 aggregate.py > "$1"
}

# Build and install the original GC
../boehm/install.sh -original -build-gc
benchmark "result-baseline.tsv"

# Now for the new version
../boehm/install.sh -buffer 16 -build-gc
benchmark "result-writewatch.tsv"