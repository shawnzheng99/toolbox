import os

def list_file_extensions(directory, output_file):
    extensions = set()
    
    # Walk through all files and subdirectories in the given directory
    for root, _, files in os.walk(directory):
        for file in files:
            # Extract the file extension
            _, ext = os.path.splitext(file)
            # Add the extension to the set
            if ext:
                extensions.add(ext)
    
    # Write the extensions to the output file
    with open(output_file, 'w') as f:
        for ext in sorted(extensions):
            f.write(ext + '\n')

if __name__ == "__main__":
    directory = input("Enter the path of the directory: ")
    output_file = "file_extensions.txt"
    
    list_file_extensions(directory, output_file)
    print(f"File extensions have been written to {output_file}")