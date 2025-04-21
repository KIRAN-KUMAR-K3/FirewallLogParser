import gzip
import csv
import os
import re
from datetime import datetime
from multiprocessing import Pool, cpu_count
from tkinter import Tk, Label, Button, filedialog, Entry, StringVar
from tkinter.ttk import Progressbar
from tqdm import tqdm
import threading

# === Constants ===
LOG_DIR = "/mnt/Firewall-Logs/Firewall-Logs/Firewall"

FIELDS = [
    "date", "time", "log_type", "status", "fw_rule_id", "fw_rule_name",
    "src_ip", "dst_ip", "protocol", "dst_country_code",
    "src_port", "dst_port", "tran_src_ip"
]

REGEX = {k: re.compile(fr'{k}="?([^"\s]+)"?') for k in FIELDS}
DATE_RE = re.compile(r'\.(\d{2})\.(\d{2})\.(\d{2})\.gz$')


def process_file(args):
    file, DATE_START, DATE_END, IP_SET = args
    matches = []
    match = DATE_RE.search(file)
    if not match:
        return []

    day, month, year = match.groups()
    log_date = datetime.strptime(f"20{year}-{month}-{day}", "%Y-%m-%d")

    if not (DATE_START <= log_date <= DATE_END):
        return []

    file_path = os.path.join(LOG_DIR, file)
    log_date_str = log_date.strftime("%Y-%m-%d")

    try:
        with gzip.open(file_path, "rt", errors="ignore") as f:
            for line in f:
                if not any(ip in line for ip in IP_SET):
                    continue

                row = {"date": log_date_str}
                for key, rgx in REGEX.items():
                    if key == "date":
                        continue
                    match = rgx.search(line)
                    row[key] = match.group(1) if match else ""
                matches.append(row)
    except Exception as e:
        print(f"⚠️ Error reading {file}: {e}")

    return matches


def start_parsing(ips_path, start_date_str, end_date_str, output_dir):
    DATE_START = datetime.strptime(start_date_str, "%Y-%m-%d")
    DATE_END = datetime.strptime(end_date_str, "%Y-%m-%d")

    with open(ips_path, "r") as f:
        IP_SET = set(ip.strip() for ip in f if ip.strip())

    all_files = [f for f in os.listdir(LOG_DIR) if f.endswith(".gz")]
    args = [(f, DATE_START, DATE_END, IP_SET) for f in all_files]

    results = []
    with Pool(cpu_count()) as pool:
        for res in tqdm(pool.imap_unordered(process_file, args), total=len(all_files), desc="🔍 Scanning Logs"):
            results.extend(res)

    output_file = os.path.join(output_dir, "parsed_firewall_logs.csv")
    with open(output_file, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(results)

    print("✅ Done. Combined logs saved at:", output_file)


# === GUI ===
def run_gui():
    def browse_file(var):
        filename = filedialog.askopenfilename()
        if filename:
            var.set(filename)

    def browse_dir(var):
        dirname = filedialog.askdirectory()
        if dirname:
            var.set(dirname)

    def start_thread():
        threading.Thread(
            target=start_parsing,
            args=(ips_file.get(), start_date.get(), end_date.get(), output_dir.get())
        ).start()

    root = Tk()
    root.title("🔥 Fast Firewall Log Parser")
    root.geometry("600x350")

    ips_file = StringVar()
    output_dir = StringVar()
    start_date = StringVar(value="2025-04-07")
    end_date = StringVar(value="2025-04-14")

    row = 0
    Label(root, text="Select IP List File (ips.txt):").grid(row=row, column=0, sticky="w")
    Entry(root, textvariable=ips_file, width=50).grid(row=row, column=1)
    Button(root, text="Browse", command=lambda: browse_file(ips_file)).grid(row=row, column=2)

    row += 1
    Label(root, text="Start Date (YYYY-MM-DD):").grid(row=row, column=0, sticky="w")
    Entry(root, textvariable=start_date).grid(row=row, column=1, sticky="w")

    row += 1
    Label(root, text="End Date (YYYY-MM-DD):").grid(row=row, column=0, sticky="w")
    Entry(root, textvariable=end_date).grid(row=row, column=1, sticky="w")

    row += 1
    Label(root, text="Select Output Directory:").grid(row=row, column=0, sticky="w")
    Entry(root, textvariable=output_dir, width=50).grid(row=row, column=1)
    Button(root, text="Browse", command=lambda: browse_dir(output_dir)).grid(row=row, column=2)

    row += 2
    Button(root, text="🚀 Start Parsing", bg="green", fg="white", font=("Arial", 12, "bold"), command=start_thread).grid(row=row, column=1, pady=20)

    root.mainloop()


if __name__ == "__main__":
    run_gui()
