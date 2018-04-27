#1/bin/sh

# $1 contains whether this is mwritten or baseline
# $2 contains the filename

name=`basename $2`
echo "Running: $name"
echo "$name" | tr "\n" "\t" >> "results-$1.unaggregated.tsv"
sudo rtprio 0 /usr/bin/time -a -o "results-$1.unaggregated.tsv" see-shell -f "./sunspider-0.9/$name"

sed -i '' -e $'s/real/\t/g' "results-$1.unaggregated.tsv"
sed -i '' -e $'s/user/\t/g' "results-$1.unaggregated.tsv"
sed -i '' -e $'s/sys//g' "results-$1.unaggregated.tsv"
sed -i '' -e $'s/ //g' "results-$1.unaggregated.tsv"
