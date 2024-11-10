import csv
import sys

# Define file paths
input_csv_path = sys.argv[1]  # Path to the input CSV file
output_csv_path = sys.argv[2]  # Path for the output CSV file

# Open the input CSV file and the output CSV file
with open(input_csv_path, 'r', encoding='utf-8-sig') as infile, open(output_csv_path, 'w', newline='', encoding='utf-8') as outfile:
    # Initialize CSV reader and writer
    csv_reader = csv.DictReader(infile)
    output_fieldnames = ['UserName', 'GroupName']
    csv_writer = csv.DictWriter(outfile, fieldnames=output_fieldnames)
    
    # Write header for the output file
    csv_writer.writeheader()
    
    # Process each row in the input CSV file
    for row_number, row in enumerate(csv_reader, start=2):  # Start at 2 to account for header row
        # Get GroupName
        group_name = row['GroupName']
        
        # Use UserName if it's not empty; otherwise, use ServiceName
        user_name = row['UserName'].strip() if row['UserName'].strip() else row['ServiceName'].strip()
        
        # Write to the output CSV file
        csv_writer.writerow({
            'UserName': user_name,
            'GroupName': group_name
        })

print("Output file generated successfully:", output_csv_path)

