import csv
import re
import sys

# Define file paths
input_csv_path = sys.argv[1]  # Path to the input CSV file
output_csv_path = sys.argv[2]  # Path for the output CSV file

# Regular expression pattern to check if UserName is an email address
email_pattern = re.compile(r"^[\w\.-]+@[\w\.-]+\.\w+$")

# Open the input CSV file and the output CSV file
with open(input_csv_path, 'r', encoding='utf-8-sig') as infile, open(output_csv_path, 'w', newline='', encoding='utf-8') as outfile:
    # Initialize CSV reader and writer
    csv_reader = csv.DictReader(infile)
    output_fieldnames = ['UserName', 'Group']
    csv_writer = csv.DictWriter(outfile, fieldnames=output_fieldnames)
    
    # Write header for the output file
    csv_writer.writeheader()
    
    # Process each row in the input CSV file
    for row in csv_reader:
        # Check if UserName is an email address
        user_name = row['UserName'].strip()
        if email_pattern.match(user_name):
            formatted_user_name = user_name
        else:
            formatted_user_name = f"sp:{user_name}"
        
        # Prefix GroupName with "group:"
        group = f"group:{row['GroupName'].strip()}"
        
        # Write to the output CSV file
        csv_writer.writerow({
            'UserName': formatted_user_name,
            'Group': group
        })

print("Output file generated successfully:", output_csv_path)

