#!/usr/local/bin/bash

# This benchmark tests how the GC performs for different sized programs, by
# timing the GC against the Boehm microbenchmark across a range of parameter
# values (e.g. different size trees for the benchmark to manipulate).

# Options:
#
#   -result-prefix           Prefix given to results file
#   -writewatch-only         Only run the benchmark on the writewatch enabled
#                            variant of Boehm.
#   -original-only           Only run the benchmark on the unaltered variant of
#                            Boehm.

benchmark()
{
  # Build the benchmarker, linking BDWGC
  cc -I./gc/include benchmark.c ./gc/lib/libgc.so -o benchmark
  chmod +x ./benchmark

  # Begin the benchmark. $1 is the file to save the content into.

  echo ">>> Running benchmark HEAP_SIZE..."
  echo "kStretchTreeDepth	LongLivedTreeDepth	kArraySize	kMinTreeDepth	kMaxTreeDepth	GC Itertations	Heap Size	Time Elapsed\
" > "$1"

  for ((kStretchTreeDepth = 18; kStretchTreeDepth <= 21; kStretchTreeDepth++));
  do
    for ((kLongLivedTreeDepth = 16; kLongLivedTreeDepth <= 19; kLongLivedTreeDepth++));
    do
      for ((i=1;i<=30;i++));
      do
        echo "Iter $i: kStretchTreeDepth=$kStretchTreeDepth kLongLivedTreeDepth=$kLongLivedTreeDepth"
        rtprio 0 ./benchmark "$kStretchTreeDepth" "$kLongLivedTreeDepth" >> "$1"
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
  benchmark "$1-baseline.tsv"
}

writewatch()
{
  # === NEW GC ===
  # Build and install the GC. Specify a 16-address buffer if requested.
  ./install.sh -buffer 16 -build-gc

  # Run benchmark and save results in benchmark-writewatch.tsv
  benchmark "$1-writewatch.tsv"
}

prefix="results"

if [ "$1" == "-results-prefix" ]; then
  shift
  prefix="$1"
  shift
fi

if [ "$1" == "-writewatch-only" ]; then
  shift
  writewatch $prefix
elif [ "$1" == '-original-only' ]; then
  shift
  original $prefix
else
  original $prefix
  writewatch $prefix
fi
