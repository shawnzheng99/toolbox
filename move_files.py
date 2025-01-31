import os
import shutil

def move_files_to_destination(source_dir, destination_dir):
    # Create the destination directory if it doesn't exist
    output_folder = os.path.join(destination_dir, "output_vids")
    os.makedirs(output_folder, exist_ok=True)

    # Traverse through the source directory recursively
    for root, _, files in os.walk(source_dir):
        for file in files:
            # Get the full path of the file in the source directory
            source_file = os.path.join(root, file)
            
            # Determine the destination path
            destination_file = os.path.join(output_folder, file)
            
            # Handle duplicate file names
            if os.path.exists(destination_file):
                base_name, extension = os.path.splitext(file)
                count = 1
                while True:
                    new_file_name = f"{base_name}-{count}{extension}"
                    destination_file = os.path.join(output_folder, new_file_name)
                    if not os.path.exists(destination_file):
                        break
                    count += 1

            # Move the file to the destination folder
            shutil.move(source_file, destination_file)
            print(f"Moved {source_file} to {destination_file}")

    print(f"All files moved to {output_folder}")

if __name__ == "__main__":
    source_dir = input("Enter the source directory path: ")
    destination_dir = input("Enter the destination directory path: ")

    move_files_to_destination(source_dir, destination_dir)