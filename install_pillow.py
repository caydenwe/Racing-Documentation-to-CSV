# python -c "import PIL" >nul 2>&1
# if %errorlevel% neq 0 (
#     echo Pillow is not installed. Installing...
#     pip install pillow
# ) else (
#     echo Pillow is already installed.
# )

import subprocess, sys

def check_pillow():
    try:
        # Check if Pillow is installed using pip list
        installed_packages = subprocess.check_output([sys.executable, "-m", "pip", "list"]).decode("utf-8")
        
        # Search for Pillow in the list of installed packages
        if "pillow" in installed_packages:
            print("Pillow is already installed.")
        else:
            print("Pillow is not installed. Installing now...")
            # Install Pillow if not found
            subprocess.check_call([sys.executable, "-m", "pip", "install", "pillow"])
            print("Pillow has been successfully installed.")
    
    except subprocess.CalledProcessError:
        print("An error occurred while checking or installing Pillow.")


if __name__ == "__main__":
    check_pillow()