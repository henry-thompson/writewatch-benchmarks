#!/usr/local/bin/bash

git clone https://github.com/ecraven/r7rs-benchmarks

benchmark()
{
  cd r7rs-benchmarks

  # Clear the log file after previous runs.
  rm results.Guile

  # Run the benchmarks 30 times.
  ./bench -r 30 guile all

  # Log output is in results.Guile, extract runtimes.
  echo "Runtime,Benchmark,Time (s)" > "../$1"
  grep -a -h '+!CSVLINE' results.Guile | sed 's/+!CSVLINE!+//' >> "../$1"

  # And collate them all.
  python2 aggregate.py "../$1" > "../$2"

  cd ..
}

# Install Boehm GC (original) and run benchmarks
cd ../boehm
sudo ./install.sh -original -build-gc
cd ../guile
benchmark "results-baseline.unaggregated.tsv" "results-baseline.tsv"

# Install Boehm GC (modified) and run benchmarks
cd ../boehm
sudo ./install.sh -build-gc
cd ../guile
benchmark "results-mwritten.unaggregated.tsv" "results-mwritten.tsv"