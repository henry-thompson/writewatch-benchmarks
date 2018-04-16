#!/usr/local/bin/bash

# Build the benchmark
echo "Building benchmark"
cc ../mprotect-vs-mww/mprotect-vs-mww.c -o benchmark

rm *.tsv
rm *.csv

# Run it across a range of heap sizes
pagesize=4096
writes="$1"

echo "heapsize,writes,mode,results" > results.unaggregated.csv

for((heapsize = 4096; heapsize <= 1024*1024*512; heapsize *= 2))
do
  echo "Heapsize: $heapsize | Writes: $writes | Fragments: $fragments | mprotect"
  echo -n "$heapsize,$writes,$fragments,mprotect," >> results.unaggregated.csv
  pmcstat -d -p ./benchmark p "$heapsize" "$writes" 1 >> results.unaggregated.csv

  echo "Heapsize: $heapsize | Writes: $writes | Fragments: $fragments | mwritewatch"
  echo -n "$heapsize,$writes,$fragments,mwritewatch," >> results.unaggregated.csv
  ./benchmark w "$heapsize" "$writes" 1 >> results.unaggregated.csv

  echo "Heapsize: $heapsize | Writes: $writes | Fragments: $fragments | none"
  echo -n "$heapsize,$writes,$fragments,none," >> results.unaggregated.csv
  ./benchmark n "$heapsize" "$writes" 1 >> results.unaggregated.csv
done

python2 aggregate.py results.unaggregated.csv > results.tsv
