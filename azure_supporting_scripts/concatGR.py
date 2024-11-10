import csv
import sys

# Define file paths
input_csv_path = sys.argv[1]  # Path to the input CSV file
output_csv_path = sys.argv[2]  # Path for the output CSV file

# Open the input CSV file and the output CSV file
with open(input_csv_path, 'r', encoding='utf-8-sig') as infile, open(output_csv_path, 'w', newline='', encoding='utf-8') as outfile:
    # Initialize CSV reader and writer
    csv_reader = csv.DictReader(infile)
    output_fieldnames = ['Group', 'CombinedTypeResource']
    csv_writer = csv.DictWriter(outfile, fieldnames=output_fieldnames)
    
    # Write header for the output file
    csv_writer.writeheader()
    
    # Process each row in the input CSV file
    for row in csv_reader:
        # Add "group:" prefix to GroupName
        group = f"group:{row['GroupName']}"
        
        # Combine Type and Resource with a colon
        combined_type_resource = f"{row['Type']}:{row['Resource']}"
        
        # Write to the output CSV file
        csv_writer.writerow({
            'Group': group,
            'CombinedTypeResource': combined_type_resource
        })

print("Output file generated successfully:", output_csv_path)

