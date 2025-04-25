"""
INI Files Aggregator and Ingestor Script
----------------------------------------

Version: 1.1.0
Date: 2025-04-26
Author: Cayden Wellsmore
"""

import configparser, csv, glob, os, re, shutil, subprocess, sys
import tkinter as tk
import tkinter.messagebox as messagebox
from datetime import datetime
from tkinter import filedialog


def get_folders(path):
    return [f for f in os.listdir(path) if os.path.isdir(os.path.join(path, f))]

def select_directory_gui(directory):
    root = tk.Tk()
    root.withdraw()
    return filedialog.askdirectory(initialdir=directory, title="Select Directory")

def get_ini_files(directory):
    files = glob.glob(os.path.join(directory, '*.ini'))
    pattern = re.compile(r'^[A-Z]{3} \d{1,2} Setup [A-Z]$', re.IGNORECASE)

    # Validate all filenames
    invalid_files = [
        os.path.basename(f) for f in files
        if not pattern.match(os.path.splitext(os.path.basename(f))[0])
    ]

    if invalid_files:
        error_message = (
            "The naming convention of the files in the folder you selected "
            "isn't consistent with the predetermined naming convention.\n\n"
            "Expected format: MMM D Setup L\n"
            "Examples: 'FEB 1 Setup A', 'Apr 9 Setup C'\n\n"
            f"Issue found with:\n{chr(10).join(invalid_files)}"
        )
        messagebox.showerror("Filename Error", error_message)
        sys.exit(1)

    def sort_key(file):
        name = os.path.splitext(os.path.basename(file))[0]
        match = re.match(r'([A-Z]{3}) (\d{1,2}) setup ([A-Z])', name, re.IGNORECASE)
        month_str, day_str, suffix = match.groups()
        date_part = datetime.strptime(f"{month_str.upper()} {int(day_str)}", "%b %d")
        return (date_part, suffix.upper())

    return sorted(files, key=sort_key)

def move_ingested_files(file_paths):
    files_to_be_ingested_path = os.path.dirname(file_paths[0])
    destination_folder = os.path.join(files_to_be_ingested_path, 'Ingested')
    if not os.path.exists(destination_folder):
        os.makedirs(destination_folder)
    for file_path in file_paths:
        try:
            ini_filename = os.path.basename(file_path)
            sp_filename = os.path.splitext(ini_filename)[0] + ".sp"
            shutil.move(file_path, os.path.join(destination_folder, ini_filename))
            shutil.move(os.path.splitext(file_path)[0] + ".sp", os.path.join(destination_folder, sp_filename))
            print(f"Moved: {ini_filename} and {sp_filename} to {destination_folder}")
        except Exception as e:
            print(f"Error moving file {file_path}: {e}")

def main():
    current_dir = os.getcwd()
    directories = get_folders(current_dir)
    if not directories:
        print("No directories found in the current directory.")
        return

    selected_directory = select_directory_gui(current_dir)
    if not selected_directory:
        print("No directory selected.")
        return

    print(f"You selected the directory: {selected_directory}")
    
    ini_files = get_ini_files(selected_directory)
    if not ini_files:
        print(f"No .ini files found in {selected_directory}.")
        return

    # --- Step 1: Collect headers ---
    all_headers_sets = []
    all_headers_order = []
    seen_headers = set()

    for file in ini_files:
        config = configparser.ConfigParser()
        config.read(file)
        headers = set()
        for section in config.sections():
            if section not in ['CAR', '__EXT_PATCH']:
                headers.add(section)
                if section not in seen_headers:
                    all_headers_order.append(section)
                    seen_headers.add(section)
        all_headers_sets.append(headers)

    # Identify common headers (intersection across all files)
    common_headers = set.intersection(*all_headers_sets) if all_headers_sets else set()
    common_headers = sorted(common_headers)  # Alphabetical order

    # Identify additional headers (those not common)
    additional_headers = [h for h in all_headers_order if h not in common_headers]  # Keep first-seen order

    # Final header list
    final_headers = common_headers + additional_headers

    print(f"Common headers: {common_headers}")
    print(f"Additional headers: {additional_headers}")
    print(f"Final headers: {final_headers}")
    
    outputfile_path = os.path.join(selected_directory, 'output.csv')

    # --- Step 2: Write CSV file ---
    with open(outputfile_path, mode='w', newline='') as file:
        writer = csv.writer(file)
        header_row = ['filename', ''] + final_headers
        writer.writerow(header_row)

        # --- Step 3: Process each .ini file ---
        for file in ini_files:
            filename = os.path.splitext(os.path.basename(file))[0]
            print(f"Reading file: {filename}")
            config = configparser.ConfigParser()
            config.read(file)

            # Gather values for all headers in final_headers list
            values_dict = {}
            for header in final_headers:
                try:
                    value = int(list(config[header].items())[0][1])  # Extract first value as integer
                except (IndexError, ValueError, KeyError):
                    value = ''  # Leave empty if not found or invalid
                values_dict[header] = value

            # Prepare data row in the same order as headers
            data_row = [filename, ''] + [values_dict[h] for h in final_headers]
            writer.writerow(data_row)

    move_ingested_files(ini_files)
    print("Process completed successfully.")
    print(f"Opening folder: {outputfile_path}")
    subprocess.run(['explorer', f'/select,{outputfile_path}'])

if __name__ == "__main__":
    main()