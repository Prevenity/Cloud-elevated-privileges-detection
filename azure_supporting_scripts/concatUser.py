import csv
import sys

# Define file paths
input_csv_path = sys.argv[1]  # Path to the input CSV file
output_csv_path = sys.argv[2]  # Path for the output CSV file

# Open the input CSV file and the output CSV file
with open(input_csv_path, 'r', encoding='utf-8-sig') as infile, open(output_csv_path, 'w', newline='', encoding='utf-8') as outfile:
    # Initialize CSV reader and writer
    csv_reader = csv.DictReader(infile)
    output_fieldnames = ['UserName', 'CombinedTypeResource']
    csv_writer = csv.DictWriter(outfile, fieldnames=output_fieldnames)
    
    # Write header for the output file
    csv_writer.writeheader()
    
    # Process each row in the input CSV file
    for row in csv_reader:
        # Leave UserName as is
        user_name = row['UserName']
        
        # Check if Type contains "subscriptions"
        type_value = row['Type'].strip()
        resource_value = row['Resource'].strip()
        
        # Combine Type and Resource or leave as Type based on condition
        if "subscriptions" in type_value:
            combined_value = type_value
        else:
            combined_value = f"{type_value}:{resource_value}"
        
        # Write to the output CSV file
        csv_writer.writerow({
            'UserName': user_name,
            'CombinedTypeResource': combined_value
        })

print("Output file generated successfully:", output_csv_path)

