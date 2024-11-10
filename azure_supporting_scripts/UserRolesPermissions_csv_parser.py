import csv
import sys

# Define file paths
input_csv_path = sys.argv[1]  # Path to the input CSV file
external_file_path = 'Roles.txt'  # Path to the external file with Role values to compare
output_csv_path = sys.argv[2]  # Path for the output CSV file

# Read the values from the external file into a set for faster lookups
with open(external_file_path, 'r', encoding='utf-8') as file:
    roles_to_check = set(line.strip() for line in file if line.strip())

# Open the input CSV file and the output CSV file
with open(input_csv_path, 'r', encoding='utf-8-sig') as infile, open(output_csv_path, 'w', newline='', encoding='utf-8') as outfile:
    # Initialize CSV reader and writer
    csv_reader = csv.DictReader(infile)
    
    # Debug: Print the actual headers read
    #print("CSV Headers:", csv_reader.fieldnames)
    
    # Define output headers and initialize CSV writer
    output_fieldnames = ['UserName', 'Type', 'Resource']
    csv_writer = csv.DictWriter(outfile, fieldnames=output_fieldnames)
    csv_writer.writeheader()
    
    # Process each row in the input CSV file
    for row_number, row in enumerate(csv_reader, start=2):  # Start at 2 to account for header row
        try:
            # Access fields directly using updated headers
            user_name = row['UserName']
            role = row['Role']
            scope = row['Scope']
            
            # Check if the Role in the current row matches any of the values from the external file
            if role in roles_to_check:
                # Determine Type and Resource based on Scope value
                if scope == "/":
                    type_value = "subscriptions"
                    resource_value = ""
                else:
                    # Split the Scope by "/" and get the last two components
                    scope_parts = scope.strip().split('/')
                    if len(scope_parts) >= 2:
                        type_value = scope_parts[-2]
                        resource_value = scope_parts[-1]
                    else:
                        print(f"Row {row_number}: Scope '{scope}' does not have enough parts.")
                        continue  # Skip to the next row if Scope is not in the expected format
                    
                # Write the extracted data to the output CSV
                csv_writer.writerow({
                    'UserName': user_name,
                    'Type': type_value,
                    'Resource': resource_value
                })

        except KeyError as e:
            print(f"Row {row_number}: Missing expected column - {e}")
        except Exception as e:
            print(f"Row {row_number}: Unexpected error - {e}")

print("Output file generated successfully:", output_csv_path)

