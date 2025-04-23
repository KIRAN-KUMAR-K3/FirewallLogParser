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
    (( file_epoch < start_epoch || file_epoch > end_epoch )) && continue

    echo "📦 Processing: $file_date → $(basename "$file")"

    LC_ALL=C zcat "$file" | grep -Ff "$IP_LIST" | awk -v date="$file_date" '
    BEGIN {
        FS=" ";
        OFS=",";
    }
    {
        # Initialize fields
        time="NA"; log_type="NA"; status="NA"; fw_rule_id="NA"; fw_rule_name="NA";
        src_ip="NA"; dst_ip="NA"; protocol="NA"; dst_country_code="NA";
        src_port="NA"; dst_port="NA"; tran_src_ip="NA";

        for (i = 1; i <= NF; i++) {
            if ($i ~ /^time=/) time=gensub(/.*="?([^"]+)"?/, "\\1", "g", $i)
            else if ($i ~ /^log_type=/) log_type=gensub(/.*="?([^"]+)"?/, "\\1", "g", $i)
            else if ($i ~ /^status=/) status=gensub(/.*="?([^"]+)"?/, "\\1", "g", $i)
            else if ($i ~ /^fw_rule_id=/) fw_rule_id=gensub(/.*="?([^"]+)"?/, "\\1", "g", $i)
            else if ($i ~ /^fw_rule_name=/) fw_rule_name=gensub(/.*="?([^"]+)"?/, "\\1", "g", $i)
            else if ($i ~ /^src_ip=/) src_ip=gensub(/.*="?([^"]+)"?/, "\\1", "g", $i)
            else if ($i ~ /^dst_ip=/) dst_ip=gensub(/.*="?([^"]+)"?/, "\\1", "g", $i)
            else if ($i ~ /^protocol=/) protocol=gensub(/.*="?([^"]+)"?/, "\\1", "g", $i)
            else if ($i ~ /^dst_country_code=/) dst_country_code=gensub(/.*="?([^"]+)"?/, "\\1", "g", $i)
            else if ($i ~ /^src_port=/) src_port=gensub(/.*="?([^"]+)"?/, "\\1", "g", $i)
            else if ($i ~ /^dst_port=/) dst_port=gensub(/.*="?([^"]+)"?/, "\\1", "g", $i)
            else if ($i ~ /^tran_src_ip=/) tran_src_ip=gensub(/.*="?([^"]+)"?/, "\\1", "g", $i)
        }

        print date, time, log_type, status, fw_rule_id, fw_rule_name, src_ip,
              dst_ip, protocol, dst_country_code, src_port, dst_port, tran_src_ip;
    }' >> "$OUTPUT_FILE"

done

echo "✅ Done. Output saved to $OUTPUT_FILE"
