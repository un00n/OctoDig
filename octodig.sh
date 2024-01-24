#!/bin/bash

# Check for required tools
if ! command -v amass &> /dev/null || ! command -v subfinder &> /dev/null; then
    echo "Please install amass and subfinder tools first."
    exit 1
fi

# Get input file and iterations from user
read -r -p "Enter the path to the domains list file: " domains_file
read -r -p "Enter the number of iterations: " iterations

# Function to enumerate subdomains using multiple tools
function enumerate_subdomains() {
    local domains_to_enumerate="$1"
    local results_file="$2"

    echo "Enumerating subdomains with amass..."
    amass enum -d "$domains_to_enumerate" -o "$results_file.amass"

    echo "Enumerating subdomains with subfinder..."
    subfinder -d "$domains_to_enumerate" -o "$results_file.subfinder"

    # Combine results from both tools, sort, and remove duplicates
    cat "$results_file.amass" "$results_file.subfinder" | sort -u > "$results_file"
    rm "$results_file.amass" "$results_file.subfinder"
}

# Main loop for iterations
domains=$(cat "$domains_file")
for i in $(seq 1 "$iterations"); do
    echo "Iteration $i:"
    results_file="results-$i.txt"
    enumerate_subdomains "$domains" "$results_file"
    domains=$(cat "$results_file")  # Update domains for the next iteration
done

# Count unique subdomains and save to a final file
echo "Final results:"
cat results-*.txt | sort -u > final-results.txt
wc -l final-results.txt
