#!/usr/local/bin/bash

git clone https://github.com/ecraven/r7rs-benchmarks

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

benchmark()
{
  cd r7rs-benchmarks

  # This is messy, but we need to copy libgc.so, which we just compiled 
  # before running this test, to libgc-threaded.so.1 as this is what
  # the guile binary links to.
  cp /usr/local/lib/libgc.so /usr/local/lib/libgc-threaded.so.1

  # Clear the log file after previous runs.
  rm results.Guile

  # Run the benchmarks 30 times.
  rtprio 0 ./bench -r 30 guile all

  # Log output is in results.Guile, extract runtimes.
  echo "Runtime,Benchmark,Time (s)" > "../$1"
  grep -a -h '+!CSVLINE' results.Guile | sed 's/+!CSVLINE!+//' >> "../$1"

  # And collate them all.
  python2 aggregate.py "../$1" > "../$2"

  cd ..
}

# Install Boehm GC (original) and run benchmarks
cd ../boehm
sudo ./install.sh -original -force-gengc -build-gc
cd ../guile
benchmark "results-baseline.unaggregated.tsv" "results-baseline.tsv"

# Install Boehm GC (modified) and run benchmarks
cd ../boehm
sudo ./install.sh -force-gengc -build-gc
cd ../guile
benchmark "results-mwritten.unaggregated.tsv" "results-mwritten.tsv"