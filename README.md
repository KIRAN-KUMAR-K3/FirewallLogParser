
# 🔥 FirewallLogParser

A fast and user-friendly Python GUI tool to **analyze firewall logs**, filter them by IPs and date range, and generate a single, structured CSV output — ideal for cybersecurity analysts and network engineers.

![Python](https://img.shields.io/badge/Python-3.8%2B-blue?logo=python)
![License](https://img.shields.io/github/license/KIRAN-KUMAR-K3/FirewallLogParser)
![Made With ❤️](https://img.shields.io/badge/Made%20with-%E2%9D%A4-red)

---

## 🧰 Features

- 🔍 **Multi-core Log Scanning** using Python's multiprocessing
- 📆 **Date-based Filtering** (Start & End)
- 📄 **Single CSV Output** with selected fields
- 🧠 **Regex-based Parsing** for deep log field extraction
- 📋 **Custom IP List Support**
- 🖥️ **User-friendly GUI** built with `tkinter`
- 🚀 **Super Fast** even with thousands of logs

---

## 📂 Sample Folder Structure

```
/mnt/Firewall-Logs/Firewall-Logs/Firewall/
├── log.07.04.25.gz
├── log.08.04.25.gz
└── log.09.04.25.gz
```

---

## ⚙️ Requirements

- Python 3.8 or higher
- Install dependencies:

```bash
pip install tqdm
```

---

## 🚀 How to Run

```bash
python firewall_log_parser.py
```

Then use the GUI to:
1. Select your `ips.txt` file
2. Choose a start and end date (format: `YYYY-MM-DD`)
3. Select the output directory
4. Click **Start Parsing**

The output will be saved as a single `.csv` file in your chosen directory.

---

## 📌 Sample `ips.txt`

```
192.168.1.10
172.16.20.5
10.0.0.2
```

---

## 🧪 Fields Extracted

- `date`, `time`, `log_type`, `status`, `fw_rule_id`, `fw_rule_name`,  
  `src_ip`, `dst_ip`, `protocol`, `dst_country_code`,  
  `src_port`, `dst_port`, `tran_src_ip`

> **Note:** MAC address field has been excluded for privacy and relevance.

---

## 📷 GUI Preview

<img src="https://raw.githubusercontent.com/KIRAN-KUMAR-K3/FirewallLogParser/main/gui-preview.png" width="600"/>

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 👨‍💻 Author

**Kiran Kumar K**  
💼 [LinkedIn](https://www.linkedin.com/in/kiran-kumar-k3)  
📁 [GitHub](https://github.com/KIRAN-KUMAR-K3)

---

## ⭐️ Support

If you like the project, leave a ⭐ on the repo — it helps a lot!

```
