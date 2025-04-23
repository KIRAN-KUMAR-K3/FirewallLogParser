#!/bin/bash

# === CONFIGURATION ===
LOG_DIR="/mnt/Firewall-Logs/Firewall-Logs/Firewall"
IP_LIST="ips.txt"
START_DATE="2025-04-07"
END_DATE="2025-04-08"
OUTPUT_FILE="parsed_firewall_logs.csv"

# === FUNCTIONS ===

# Convert YYYY-MM-DD to epoch
date_to_epoch() {
    date -d "$1" +%s 2>/dev/null || gdate -d "$1" +%s
}

# Extract date from filename: Firewall_Rules.DD.MM.YY.gz
extract_date() {
    fname=$(basename "$1")
    if [[ $fname =~ Firewall_Rules\.([0-9]{2})\.([0-9]{2})\.([0-9]{2})\.gz$ ]]; then
        echo "20${BASH_REMATCH[3]}-${BASH_REMATCH[2]}-${BASH_REMATCH[1]}"
    fi
}

# === MAIN SCRIPT ===

# Validate inputs
[[ ! -d "$LOG_DIR" ]] && echo "❌ Log directory not found: $LOG_DIR" && exit 1
[[ ! -f "$IP_LIST" ]] && echo "❌ IP list not found: $IP_LIST" && exit 1

start_epoch=$(date_to_epoch "$START_DATE")
end_epoch=$(date_to_epoch "$END_DATE")

# CSV Header
echo "date,time,log_type,status,fw_rule_id,fw_rule_name,src_ip,dst_ip,protocol,dst_country_code,src_port,dst_port,tran_src_ip" > "$OUTPUT_FILE"

# Process matching log files
for file in "$LOG_DIR"/Firewall_Rules.*.gz; do
    file_date=$(extract_date "$file")
    [[ -z "$file_date" ]] && continue

    file_epoch=$(date_to_epoch "$file_date")
    if (( file_epoch < start_epoch || file_epoch > end_epoch )); then
        continue
    fi

    echo "📦 Processing: $file_date → $(basename "$file")"

    zgrep -Ff "$IP_LIST" "$file" | awk -v date="$file_date" '
    BEGIN {
        FS=" ";
        OFS=",";
    }
    {
        # Initialize fields to "NA"
        row["date"] = date;
        row["time"] = "NA";
        row["log_type"] = "NA";
        row["status"] = "NA";
        row["fw_rule_id"] = "NA";
        row["fw_rule_name"] = "NA";
        row["src_ip"] = "NA";
        row["dst_ip"] = "NA";
        row["protocol"] = "NA";
        row["dst_country_code"] = "NA";
        row["src_port"] = "NA";
        row["dst_port"] = "NA";
        row["tran_src_ip"] = "NA";

        match($0, /time="?([^"\s]+)"?/, a); if (a[1] != "") row["time"] = a[1];
        match($0, /log_type="?([^"\s]+)"?/, a); if (a[1] != "") row["log_type"] = a[1];
        match($0, /status="?([^"\s]+)"?/, a); if (a[1] != "") row["status"] = a[1];
        match($0, /fw_rule_id="?([^"\s]+)"?/, a); if (a[1] != "") row["fw_rule_id"] = a[1];
        match($0, /fw_rule_name="?([^"\s]+)"?/, a); if (a[1] != "") row["fw_rule_name"] = a[1];
        match($0, /src_ip="?([^"\s]+)"?/, a); if (a[1] != "") row["src_ip"] = a[1];
        match($0, /dst_ip="?([^"\s]+)"?/, a); if (a[1] != "") row["dst_ip"] = a[1];
        match($0, /protocol="?([^"\s]+)"?/, a); if (a[1] != "") row["protocol"] = a[1];
        match($0, /dst_country_code="?([^"\s]+)"?/, a); if (a[1] != "") row["dst_country_code"] = a[1];
        match($0, /src_port="?([^"\s]+)"?/, a); if (a[1] != "") row["src_port"] = a[1];
        match($0, /dst_port="?([^"\s]+)"?/, a); if (a[1] != "") row["dst_port"] = a[1];
        match($0, /tran_src_ip="?([^"\s]+)"?/, a); if (a[1] != "") row["tran_src_ip"] = a[1];

        print row["date"], row["time"], row["log_type"], row["status"], row["fw_rule_id"],
              row["fw_rule_name"], row["src_ip"], row["dst_ip"], row["protocol"],
              row["dst_country_code"], row["src_port"], row["dst_port"], row["tran_src_ip"];
    }' >> "$OUTPUT_FILE"
done

echo "✅ Done. Output saved at $OUTPUT_FILE"
