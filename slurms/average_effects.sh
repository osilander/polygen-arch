output_file="effect_sizes_summary.txt"
echo -e "Filename\tAverage\tMedian" > "$output_file"

for file in per-bp-betas/*.txt; do
    echo "Processing $file..."

    # Sample 1000 rows from column 4 (absolute values)
    sample=$(shuf -n 1000 "$file" | awk '{print $4}')

    # Compute the average
    avg=$(echo "$sample" | awk '{sum += $1; count++} END {if (count > 0) printf "%.10f\n", sum / count; else print "NA"}')

    # Compute the correct median
    median=$(echo "$sample" | sort -n | awk '
        {values[NR] = $1}
        END {
            if (NR % 2 == 1) {
                print values[(NR + 1) / 2]   # Odd case: print middle value
            } else {
                print (values[NR/2] + values[NR/2 + 1]) / 2  # Even case: avg of two middle values
            }
        }')

    # Append results to output file
    echo -e "$(basename "$file")\t$avg\t$median" >> "$output_file"
done

echo "✅ Done! Results saved in $output_file"
