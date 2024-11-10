import csv
import sys

# Define file paths
input_csv_path = sys.argv[1]  # Path to the input CSV file
external_file_path = 'Roles.txt'  # Path to the external file with Role values to compare
output_csv_path = sys.argv[2]  # Path for the output CSV file

# Read the values from the external file into a set for faster lookups
with open(external_file_path, 'r') as file:
    roles_to_check = set(line.strip() for line in file)

# Open the input CSV file and the output CSV file
with open(input_csv_path, 'r', encoding='utf-8-sig') as infile, open(output_csv_path, 'w', newline='') as outfile:
    # Initialize CSV readers and writers
    csv_reader = csv.DictReader(infile)
    
    # Print headers to help with debugging
    #print("CSV Headers:", csv_reader.fieldnames)

    # Adjust fieldnames by stripping whitespace (to handle unexpected spaces in headers)
    csv_reader.fieldnames = [header.strip() for header in csv_reader.fieldnames]
    
    fieldnames = ['GroupName', 'Type', 'Resource']
    csv_writer = csv.DictWriter(outfile, fieldnames=fieldnames)
    csv_writer.writeheader()
    
    # Process each row in the input CSV file
    for row in csv_reader:
        # Strip whitespace from each key in the row to avoid key errors
        row = {key.strip(): value for key, value in row.items()}
        
        # Check if the Role in the current row matches any of the values from the external file
        if row.get('Role') in roles_to_check:
            # Extract ServicePrincipalName
            service_principal_name = row.get('GroupName')
            #print(service_principal_name) 
            # Split the Scope by "/" and get the last two components
            scope_parts = row.get('Scope', '').split('/')
            if len(scope_parts) >= 2:
                type_value = scope_parts[-2]
                resource_value = scope_parts[-1]
                
                # Write the extracted data to the output CSV
                csv_writer.writerow({
                    'GroupName': service_principal_name,
                    'Type': type_value,
                    'Resource': resource_value
                })

print("Output file generated successfully:", output_csv_path)

