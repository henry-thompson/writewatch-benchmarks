#!/usr/local/bin/bash

# This benchmark tests how the GC performs for different sized programs, by
# timing the GC against the Boehm microbenchmark across a range of parameter
# values (e.g. different size trees for the benchmark to manipulate).

# Options:
#
#   -result-prefix           Prefix given to results file
#   -mwritten-only         Only run the benchmark on the mwritten enabled
#                            variant of Boehm.
#   -original-only           Only run the benchmark on the unaltered variant of
#                            Boehm.

benchmark()
{
  # Build the benchmarker, linking BDWGC
  ./build.sh

  # Begin the benchmark. $1 is the file to save the content into.

  echo ">>> Running benchmark HEAP_SIZE..."
  echo "kStretchTreeDepth	kLongLivedTreeDepth	kArraySize	kMinTreeDepth	kMaxTreeDepth	GC Itertations	Heap Size	Time Elapsed\
" > "$1"

  for ((kMaxTreeDepth = 14; kMaxTreeDepth <= 19; kMaxTreeDepth++));
  do
    for ((kLongLivedTreeDepth = 16; kLongLivedTreeDepth <= 19; kLongLivedTreeDepth++));
    do
      for ((i=1;i<=30;i++));
      do
        echo "Iter $i: kMaxTreeDepth=$kMaxTreeDepth kLongLivedTreeDepth=$kLongLivedTreeDepth"
        rtprio 0 ./benchmark 21 "$kLongLivedTreeDepth" 5000000 4 "$kMaxTreeDepth" 3 >> "$1"
      done
    done
  done
}

original()
{
  # === OLD GC ===
  # Build and install the original GC
  ./install.sh -original -build-gc

  # Run benchmark and save results in benchmark-baseline.tsv
  benchmark "results-baseline.tsv"
  python2 aggregate.py baseline
}

mwritten()
{
  # === NEW GC ===
  # Build and install the GC. Specify a 16-address buffer if requested.
  ./install.sh -build-gc

  # Run benchmark and save results in benchmark-mwritten.tsv
  benchmark "results-mwritten.tsv"
  python2 aggregate.py mwritten
}

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ "$1" == "-mwritten-only" ]; then
  shift
  mwritten
elif [ "$1" == '-original-only' ]; then
  shift
  original
else
  original
  mwritten
fi
