import os
import shutil
import hashlib
import logging

def get_file_hash(file_path, chunk_size=8192):
    """Generate a hash for a file by reading it in chunks."""
    hasher = hashlib.md5()
    try:
        with open(file_path, 'rb') as f:
            while chunk := f.read(chunk_size):
                hasher.update(chunk)
    except Exception as e:
        logging.error(f"Error reading file {file_path}: {e}")
        return None
    return hasher.hexdigest()

def find_and_move_duplicates(source_dir, dest_dir):
    """Find and move duplicate files from source_dir to dest_dir."""
    if not os.path.exists(dest_dir):
        os.makedirs(dest_dir)

    seen_hashes = {}
    total_files = sum(len(files) for _, _, files in os.walk(source_dir))
    processed_files = 0

    for root, _, files in os.walk(source_dir):
        for file in files:
            file_path = os.path.join(root, file)
            file_hash = get_file_hash(file_path)

            if file_hash is None:
                continue  # Skip file if there was an error reading it

            if file_hash in seen_hashes:
                duplicate_file_path = os.path.join(dest_dir, file)
                try:
                    shutil.move(file_path, duplicate_file_path)
                    logging.info(f"Moved duplicate file: {file_path} to {duplicate_file_path}")
                except Exception as e:
                    logging.error(f"Error moving file {file_path} to {duplicate_file_path}: {e}")
            else:
                seen_hashes[file_hash] = file_path
            
            processed_files += 1
            print(f"Processed {processed_files}/{total_files} files...", end='\r')

if __name__ == "__main__":
    source_directory = input("Enter the path of the source directory: ")
    destination_directory = input("Enter the path of the destination directory: ")

    logging.basicConfig(filename='file_duplicates.log', level=logging.INFO,
                        format='%(asctime)s - %(levelname)s - %(message)s')

    find_and_move_duplicates(source_directory, destination_directory)