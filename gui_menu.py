import os,subprocess, sys, urllib.request, importlib.util, runpy
import tkinter as tk
from install_pillow import check_pillow

# Function to download a file from a URL
def download_file(url, save_path):
    try:
        urllib.request.urlretrieve(url, save_path)
        print(f"{os.path.basename(save_path)} downloaded successfully.")
    except Exception as e:
        print(f"Error downloading {os.path.basename(save_path)}: {e}")

# Function to execute PowerShell or batch scripts
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
    script_dir = os.path.dirname(__file__)
    sys.path.insert(0, script_dir)  # Add script dir to the path
    try:
        import ini_to_csv
        ini_to_csv.main()  # Assuming the script has a main() function
    finally:
        sys.path.pop(0)  # Clean up path

# Handle button clicks
def on_button_click(option):
    if option == "report":
        print("Reporting a bug or requesting a feature...")
        report_bug()
    elif option == "update":
        print("Checking for updates...")
        check_for_updates()
    elif option == "run_python":
        print("Running Python script...")
        run_python_script()

# GUI creation
def create_gui():
    root = tk.Tk()
    root.title("Select an Option")
    root.geometry("300x200")
    tk.Button(root, text="Report a Bug / Request Feature", width=25, command=lambda: on_button_click("report")).pack(pady=10)
    tk.Button(root, text="Check for Updates", width=25, command=lambda: on_button_click("update")).pack(pady=10)
    tk.Button(root, text="Run Python Script", width=25, command=lambda: on_button_click("run_python")).pack(pady=10)
    root.mainloop()

# Main
if __name__ == "__main__":
    check_pillow()
    create_gui()