#!/usr/local/bin/bash

# Build the benchmark
echo "Building benchmark"
cc mprotect-vs-mww.c -o benchmark

rm *.tsv
rm *.csv

# Run it across all the possible configurations
pagesize=4096

echo "heapsize,writes,fragments,mode,results" > results.unaggregated.csv

for((heapsize = 4096; heapsize <= 2*1024*1024*1024; heapsize *= 2))
do
	zerowritesdone="no"
	for((writes = heapsize / $pagesize; writes >= 0; writes /= 2))
	do
		for((fragments = 1; fragments <=1; fragments *= 2))
		do
			echo "Heapsize: $heapsize | Writes: $writes | Fragments: $fragments | mprotect"
			echo -n "$heapsize,$writes,$fragments,mprotect," >> results.unaggregated.csv
			./benchmark p "$heapsize" "$writes" "$fragments" >> results.unaggregated.csv
			
			echo "Heapsize: $heapsize | Writes: $writes | Fragments: $fragments | mwritten"
			echo -n "$heapsize,$writes,$fragments,mwritten," >> results.unaggregated.csv
			./benchmark w "$heapsize" "$writes" "$fragments" >> results.unaggregated.csv
			
			echo "Heapsize: $heapsize | Writes: $writes | Fragments: $fragments | none"
			echo -n "$heapsize,$writes,$fragments,none," >> results.unaggregated.csv
			./benchmark n "$heapsize" "$writes" "$fragments" >> results.unaggregated.csv
		done

		if [[ "$writes" == "0" ]]; then
			break
		fi
	done
done

python2 aggregate.py results.unaggregated.csv
