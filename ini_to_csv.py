"""
INI Files Aggregator and Ingestor Script
----------------------------------------

Version: 1.2.0
Date: 2025-04-26 
Author: Cayden Wellsmore
"""

import os, subprocess, sys,urllib.request, re, glob, shutil, configparser, csv, logging
import tkinter as tk
from tkinter import messagebox, filedialog
from datetime import datetime

logging.basicConfig(filename="log.txt", level=logging.DEBUG)

class CreateToolTip:
    def __init__(self, widget, text):
        self.widget = widget
        self.text = text
        self.tip_window = None
        widget.bind("<Enter>", self.show_tip)
        widget.bind("<Leave>", self.hide_tip)

    def show_tip(self, event=None):
        if self.tip_window or not self.text:
            return
        x, y, _cx, cy = self.widget.bbox("insert")
        x += self.widget.winfo_rootx() + 25
        y += cy + self.widget.winfo_rooty() + 25
        self.tip_window = tw = tk.Toplevel(self.widget)
        tw.wm_overrideredirect(True)
        tw.wm_geometry(f"+{x}+{y}")
        label = tk.Label(tw, text=self.text, justify="left",
                         background="#ffffe0", relief="solid", borderwidth=1,
                         font=("tahoma", "8", "normal"))
        label.pack(ipadx=5, ipady=2)

    def hide_tip(self, event=None):
        if self.tip_window:
            self.tip_window.destroy()
            self.tip_window = None

def check_pillow():
    if getattr(sys, 'frozen', False):
        # If running as a PyInstaller EXE, don't check/install Pillow
        logging.debug("Running in EXE, skipping pillow check.")
        return
    try:
        installed_packages = subprocess.check_output([sys.executable, "-m", "pip", "list"]).decode("utf-8")
        if "pillow" in installed_packages:
            logging.debug("Pillow is already installed.")
        else:
            print("Pillow is not installed. Installing now...")
            subprocess.check_call([sys.executable, "-m", "pip", "install", "pillow"])
            print("Pillow has been successfully installed.")
    except subprocess.CalledProcessError:
        print("An error occurred while checking or installing Pillow.")

def download_file(url, save_path):
    try:
        urllib.request.urlretrieve(url, save_path)
        print(f"Downloaded: {os.path.basename(save_path)}")
    except Exception as e:
        print(f"Error downloading {os.path.basename(save_path)}: {e}")

def execute_script(script_path):
    if script_path.endswith('.ps1'):
        subprocess.call(['powershell', '-ExecutionPolicy', 'Bypass', '-File', script_path])
    elif script_path.endswith('.bat'):
        subprocess.call([script_path])

def report_bug():
    """Download and run the bug reporting powershell script."""
    script_path = os.path.join(os.path.dirname(__file__), "report.ps1")
    if not os.path.exists(script_path):
        download_file(
            "https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/main/report.ps1",
            script_path
        )
    execute_script(script_path)
    try:
        os.remove(script_path)
    except Exception:
        pass
    messagebox.showinfo("Done", "Bug report or feature request submitted.")

def check_for_updates():
    """Download and run the update checking batch script."""
    batch_path = os.path.join(os.path.dirname(__file__), "setup_or_check_for_update.bat")
    if not os.path.exists(batch_path):
        download_file(
            "https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/main/setup_or_check_for_update.bat",
            batch_path
        )
    execute_script(batch_path)
    try:
        os.remove(batch_path)
    except Exception:
        pass
    messagebox.showinfo("Done", "Update check complete.")

def select_directory_gui(initial_directory):
    root = tk.Tk()
    root.withdraw()
    return filedialog.askdirectory(initialdir=initial_directory, title="Select Directory")

def get_folders(path):
    return [f for f in os.listdir(path) if os.path.isdir(os.path.join(path, f))]

def get_ini_files(directory):
    files = glob.glob(os.path.join(directory, '*.ini'))
    pattern = re.compile(r'^[A-Z]{3} \d{1,2} Setup [A-Z]$', re.IGNORECASE)

    invalid_files = [
        os.path.basename(f) for f in files
        if not pattern.match(os.path.splitext(os.path.basename(f))[0])
    ]

    if invalid_files:
        messagebox.showerror(
            "Filename Error",
            "Files do not follow naming convention:\n\n"
            "Expected: MMM D Setup L (e.g., 'FEB 1 Setup A')\n\n"
            f"Issue with:\n{chr(10).join(invalid_files)}"
        )
        sys.exit(1)

    def sort_key(file):
        name = os.path.splitext(os.path.basename(file))[0]
        match = re.match(r'([A-Z]{3}) (\d{1,2}) setup ([A-Z])', name, re.IGNORECASE)
        if match:
            month_str, day_str, suffix = match.groups()
            date_part = datetime.strptime(f"{month_str.upper()} {int(day_str)}", "%b %d")
            return (date_part, suffix.upper())
        return (datetime.now(), "")  # fallback in case of unexpected format

    return sorted(files, key=sort_key)

def move_ingested_files(file_paths):
    destination_folder = os.path.join(os.path.dirname(file_paths[0]), 'Ingested')
    os.makedirs(destination_folder, exist_ok=True)

    for file_path in file_paths:
        base, _ = os.path.splitext(file_path)
        ini_file = base + '.ini'
        sp_file = base + '.sp'

        try:
            shutil.move(ini_file, os.path.join(destination_folder, os.path.basename(ini_file)))
            shutil.move(sp_file, os.path.join(destination_folder, os.path.basename(sp_file)))
            print(f"Moved: {os.path.basename(ini_file)} and {os.path.basename(sp_file)}")
        except Exception as e:
            print(f"Error moving files: {e}")

def ini_to_csv_main():
    current_dir = os.getcwd()
    if not get_folders(current_dir):
        print("No folders found.")
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

    headers_seen = []
    headers_sets = []
    seen = set()

    for file in ini_files:
        config = configparser.ConfigParser()
        config.read(file)
        headers = set()

        for section in config.sections():
            if section not in ['CAR', '__EXT_PATCH']:
                headers.add(section)
                if section not in seen:
                    headers_seen.append(section)
                    seen.add(section)

        headers_sets.append(headers)

    common_headers = sorted(set.intersection(*headers_sets)) if headers_sets else []
    final_headers = common_headers + [h for h in headers_seen if h not in common_headers]

    outputfile_path = os.path.join(selected_directory, 'output.csv')
    outputfile_path = os.path.normpath(outputfile_path)

    with open(outputfile_path, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['filename', ''] + final_headers)

        for file_path in ini_files:
            filename = os.path.splitext(os.path.basename(file_path))[0]
            config = configparser.ConfigParser()
            config.read(file_path)

            values = []
            for header in final_headers:
                try:
                    value = int(list(config[header].items())[0][1])
                except (IndexError, ValueError, KeyError):
                    value = ''
                values.append(value)

            writer.writerow([filename, ''] + values)

    move_ingested_files(ini_files)
    print(f"Completed. Opening output: {outputfile_path}")
    subprocess.run(['explorer', f'/select,{outputfile_path}'])

def on_button_click(option):
    if option == "report":
        report_bug()
    elif option == "update":
        check_for_updates()
    elif option == "run":
        ini_to_csv_main()

def create_gui():
    root = tk.Tk()
    root.title("Select an Option")
    root.geometry("320x250")

    buttons = {
        "Report a Bug / Request Feature": "report",
        "Check for Updates": "update",
        "Run Conversion Script": "run",
        "Close": "close"
    }

    for text, action in buttons.items():
        cmd = root.destroy if action == "close" else lambda opt=action: on_button_click(opt)
        btn = tk.Button(root, text=text, width=30, command=cmd)
        btn.pack(pady=10)
        CreateToolTip(btn, f"Action: {text}")

    root.mainloop()

if __name__ == "__main__":
    check_pillow()
    create_gui()