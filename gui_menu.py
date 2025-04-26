import os,subprocess, sys, urllib.request
import tkinter as tk
from tkinter import messagebox

# Function to install Pillow if not installed
def install_pillow():
    try:
        import PIL
    except ImportError:
        print("Pillow is not installed. Installing...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
    else:
        print("Pillow is already installed.")

# Function to download a file from a URL
def download_file(url, save_path):
    try:
        urllib.request.urlretrieve(url, save_path)
        print(f"{os.path.basename(save_path)} downloaded successfully.")
    except Exception as e:
        print(f"Error downloading {os.path.basename(save_path)}: {e}")

# Function to execute PowerShell scripts or batch files
def execute_script(script_path):
    if script_path.endswith('.ps1'):
        subprocess.call(['powershell', '-ExecutionPolicy', 'Bypass', '-File', script_path])
    elif script_path.endswith('.bat'):
        subprocess.call([script_path])

# Function that runs when "Report a Bug" is clicked
def report_bug():
    script_path = os.path.join(os.path.dirname(__file__), "report.ps1")
    if not os.path.exists(script_path):
        download_file("https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/report.ps1", script_path)
    execute_script(script_path)
    os.remove(script_path)

# Function that runs when "Check for Updates" is clicked
def check_for_updates():
    script_path = os.path.join(os.path.dirname(__file__), "setup_or_check_for_update.bat")
    if not os.path.exists(script_path):
        download_file("https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/setup_or_check_for_update.bat", script_path)
    execute_script(script_path)
    os.remove(script_path)

# Function that runs when "Run Python Script" is clicked
def run_python_script():
    script_path = os.path.join(os.path.dirname(__file__), "ini_to_csv_script.py")
    if not os.path.exists(script_path):
        download_file("https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/ini_to_csv.py", script_path)
    subprocess.call([sys.executable, script_path])
    os.remove(script_path)

# Function to handle the button clicks
def on_button_click(option):
    if option == "report":
        report_bug()
    elif option == "update":
        check_for_updates()
    elif option == "run_python":
        run_python_script()

# GUI Creation using tkinter
def create_gui():
    # Create the main window
    root = tk.Tk()
    root.title("Select an Option")
    root.geometry("300x200")

    # Create buttons
    btn_report = tk.Button(root, text="Report a Bug / Request Feature", width=25, command=lambda: on_button_click("report"))
    btn_report.pack(pady=10)

    btn_update = tk.Button(root, text="Check for Updates", width=25, command=lambda: on_button_click("update"))
    btn_update.pack(pady=10)

    btn_run_python = tk.Button(root, text="Run Python Script", width=25, command=lambda: on_button_click("run_python"))
    btn_run_python.pack(pady=10)

    # Run the GUI loop
    root.mainloop()

# Main function
if __name__ == "__main__":
    # Install Pillow if necessary
    install_pillow()

    # Create and launch the GUI
    create_gui()
