import configparser, glob, os


def get_ini_files(directory):
    return glob.glob(os.path.join(directory, '*.ini'))

def find_additional_headers_per_file(ini_files):
    
    headers_per_file = {}
    all_headers_sets = []

    # Step 1: Collect headers for each file
    for file in ini_files:
        config = configparser.ConfigParser()
        config.read(file)
        headers = set(
            section for section in config.sections() if section not in ['CAR', '__EXT_PATCH']
        )
        headers_per_file[file] = headers
        all_headers_sets.append(headers)

    # Step 2: Find common headers (present in all files)
    common_headers = set.intersection(*all_headers_sets) if all_headers_sets else set()

    print(f"\nCommon headers (in all files): {sorted(common_headers)}\n")

    # Step 3: Identify additional headers in each file
    additional_headers_per_file = {}
    for file, headers in headers_per_file.items():
        additional_headers = headers - common_headers
        if additional_headers:
            additional_headers_per_file[file] = additional_headers

    # Step 4: Print files with their additional headers
    if additional_headers_per_file:
        print("Files with additional headers:")
        for file, additional_headers in additional_headers_per_file.items():
            print(f"  {os.path.basename(file)}: {sorted(additional_headers)}")
    else:
        print("No additional headers found in any file.")

    return additional_headers_per_file

# Example usage:
current_dir = os.getcwd()
directory = os.path.abspath(os.path.join(current_dir, 'Phillip Island', 'Setup files', 'Ingested'))
ini_files = get_ini_files(directory)
find_additional_headers_per_file(ini_files)