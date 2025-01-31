import os
import subprocess

def get_video_files(directory):
    video_extensions = ['.avi', '.flv', '.mkv', '.rmvb', '.wmv']
    video_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if any(file.lower().endswith(ext) for ext in video_extensions):
                video_files.append(os.path.join(root, file))
    return video_files

def convert_video(input_file):
    output_file = os.path.splitext(input_file)[0] + '.mp4'
    command = [
        'ffmpeg', '-i', input_file, '-q:v', '0', '-c:v', 'libx264', 
        '-preset', 'fast', '-c:a', 'aac', '-strict', 'experimental', output_file
    ]
    try:
        subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return output_file
    except subprocess.CalledProcessError as e:
        print(f"Failed to convert {input_file}: {e}")
        return None

def main():
    directory = input("Enter the path of the directory: ")
    output_log = "converted_files.txt"

    with open(output_log, 'w') as log_file:
        for input_file in get_video_files(directory):
            output_file = convert_video(input_file)
            if output_file:
                log_file.write(f"{input_file} converted to {output_file}\n")
                os.remove(input_file)
                print(f"Converted and removed {input_file}")

    print(f"Conversion complete! Check {output_log} for details.")

if __name__ == "__main__":
    main()