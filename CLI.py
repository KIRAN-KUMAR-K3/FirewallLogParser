import os
import gzip
import re
from concurrent.futures import ThreadPoolExecutor, as_completed
import time

# Updated input file path
INPUT_FILE = "/home/kali/Documents/ip.txt"

# Updated output file path
OUTPUT_FILE = "/home/kali/Documents/honey_res_24_31_25.csv"

# Function to process logs for a specific IP and day
def process_ip_for_day(ip, day):
    try:
        # Updated .gz log file path
        gz_file = f"/mnt/Firewall-Logs/Firewall-Logs/Firewall/Firewall_Rules.{day}.03.25.gz"
        
        # Check if the .gz file exists
        if not os.path.isfile(gz_file):
            print(f"[ERROR] Log file not found: {gz_file}. Skipping...")
            return

        print(f"[INFO] Processing log file for day: {gz_file}, IP: {ip}")

        # Open the gzipped log file and process it line by line
        with gzip.open(gz_file, 'rt') as f:
            for line in f:
                if ip in line:  # If the line contains the IP address
                    # Search for the relevant fields using regex
                    matches = re.findall(r'(?<=date=)[^ ]*|(?<=time=)[^ ]*|(?<=log_type=)[^ ]*|(?<=log_subtype=)[^ ]*|(?<=status=)[^ ]*|(?<=fw_rule_id=)[^ ]*|(?<=fw_rule_name=)[^ ]*|(?<=src_ip=)[^ ]*|(?<=dst_ip=)[^ ]*|(?<=protocol=)[^ ]*|(?<=dst_country_code=)[^ ]*|(?<=src_port=)[^ ]*|(?<=dst_port=)[^ ]*|(?<=tran_src_ip=)[^ ]*', line)
                    if matches:
                        with open(OUTPUT_FILE, 'a') as out_file:
                            out_file.write(', '.join(matches) + '\n')

        print(f"[INFO] Finished processing IP: {ip}, Day: {day}")
    except Exception as e:
        print(f"[ERROR] Error processing IP: {ip}, Day: {day}. Error: {e}")

def process_logs():
    # Read the IP addresses from the input file
    try:
        with open(INPUT_FILE, 'r') as f:
            ips = [line.strip() for line in f.readlines() if line.strip()]
        print(f"[INFO] Loaded {len(ips)} IPs for processing.")
    except Exception as e:
        print(f"[ERROR] Error reading input file: {e}")
        return

    # Start measuring the execution time
    start_time = time.time()

    # Use ThreadPoolExecutor to process logs concurrently for multiple IPs
    with ThreadPoolExecutor(max_workers=7) as executor:
        futures = []

        # For each day (24 to 30)
        for day in range(24, 31):
            day_str = f"{day:02}"
            
            # For each IP, we submit the task to the thread pool
            for ip in ips:
                futures.append(executor.submit(process_ip_for_day, ip, day_str))

        # Wait for all futures to complete and log results
        for future in as_completed(futures):
            try:
                future.result()
            except Exception as e:
                print(f"[ERROR] Exception occurred in thread: {e}")

    # End measuring the execution time
    end_time = time.time()
    print(f"[INFO] Total processing time: {end_time - start_time:.2f} seconds")

if __name__ == "__main__":
    process_logs()
