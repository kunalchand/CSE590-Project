#!/bin/bash

rm output.txt
rm -r stat_files

# Commands to execute
commands_to_execute=("csh gemTest.csh 456.hmmer baseline 1kB 1kB 1kB 1 1 1 16" 
"csh gemTest.csh 456.hmmer L1D_size_2kB 2kB 1kB 1kB 1 1 1 16"
"csh gemTest.csh 456.hmmer L1D_size_4kB 4kB 1kB 1kB 1 1 1 16"
"csh gemTest.csh 456.hmmer L1D_size_8kB 8kB 1kB 1kB 1 1 1 16"
"csh gemTest.csh 456.hmmer L1D_size_16kB 16kB 1kB 1kB 1 1 1 16"
"csh gemTest.csh 456.hmmer L1I_size_2kB 1kB 2kB 1kB 1 1 1 16"
"csh gemTest.csh 456.hmmer L1I_size_4kB 1kB 4kB 1kB 1 1 1 16"
"csh gemTest.csh 456.hmmer L1I_size_8kB 1kB 8kB 1kB 1 1 1 16"
"csh gemTest.csh 456.hmmer L1I_size_16kB 1kB 16kB 1kB 1 1 1 16"
"csh gemTest.csh 456.hmmer L1D_assoc_2 1kB 1kB 1kB 2 1 1 16"
"csh gemTest.csh 456.hmmer L1D_assoc_4 1kB 1kB 1kB 4 1 1 16"
"csh gemTest.csh 456.hmmer L1D_assoc_8 1kB 1kB 1kB 8 1 1 16"
"csh gemTest.csh 456.hmmer L1D_assoc_16 1kB 1kB 1kB 16 1 1 16"
"csh gemTest.csh 456.hmmer L2_assoc_2 1kB 1kB 1kB 1 1 2 16"
"csh gemTest.csh 456.hmmer L2_assoc_4 1kB 1kB 1kB 1 1 4 16"
"csh gemTest.csh 456.hmmer L2_assoc_8 1kB 1kB 1kB 1 1 8 16"
"csh gemTest.csh 456.hmmer L2_assoc_16 1kB 1kB 1kB 1 1 16 16"
"csh gemTest.csh 456.hmmer Block_Size_32 1kB 1kB 1kB 1 1 1 32"
"csh gemTest.csh 456.hmmer Block_Size_64 1kB 1kB 1kB 1 1 1 64"
"csh gemTest.csh 456.hmmer Block_Size_128 1kB 1kB 1kB 1 1 1 128"
"csh gemTest.csh 456.hmmer Block_Size_256 1kB 1kB 1kB 1 1 1 256"
)

# Output file
output_file="output.txt"

counter=1  # Initialize the counter

for command_to_execute in "${commands_to_execute[@]}"; do
    # Extract the word following "456.hmmer" in the command
    target_word=$(echo "$command_to_execute" | awk '{for(i=1;i<=NF;i++){if($i=="456.hmmer"){print $(i+1);break}}}')

    echo "Executing command $counter: $target_word"

    # Execute the command and capture the output
    output=$($command_to_execute 2>&1)

    # Parse the output to extract the desired information
    parsed_output=$(echo "$output" | awk '/### Test Statistics: ###/{flag=1; next} flag')

    # Extract the numbers following "total" using pattern matching
    numbers=$(echo "$parsed_output" | awk -F 'total[[:space:]]+' '{print $2}' | awk -F '[[:space:]]+#' '{print $1}')

    # Extract the number in front of "simulated" using pattern matching
    sim_insts_value=$(echo "$parsed_output" | awk '/sim_insts/ {print $(NF-5)}')

    # Append the value to the extracted numbers
    numbers+=$'\n'"$sim_insts_value"

    # Save the extracted numbers to the file
    echo "$numbers" | tr '\n' '\t' >> $output_file
    echo >> $output_file

    counter=$((counter+1))  # Increment the counter
done

# Check if the extraction and saving were successful
if [ $? -eq 0 ]; then
    echo "Extraction and saving completed successfully. Extracted numbers saved in $output_file"
else
    echo "Extraction and saving failed. Please check the error message."
fi
