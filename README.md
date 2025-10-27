# system_resource_manager
A shell/base based system resource monitoring tool with Zenity GUI that displays CPU, RAM, and Disk usage , also calculates system health and clear junk files.

# 🧠 System Resource Manager (Linux + Zenity)
### by Rishabh Nandekar (23BIT054) and Krish Shah (23BIT282D)

A **Linux shell script** project with a **Zenity-based GUI** that monitors system resources, calculates system health, and performs junk file cleanup with user interaction.

---

## 🚀 Features

- 📊 **Real-time Monitoring** — Displays CPU, RAM, and Disk usage.  
- 🧮 **Health Score Calculation** — Dynamically calculates a system health score based on resource usage.  
- 🗑️ **Junk File Cleaner** — Scans and cleans old or temporary files from a chosen directory.  
- 👀 **Preview Before Deleting** — View junk files before cleanup for safety.  
- 💡 **Interactive GUI** — Uses Zenity for dialogs, progress bars, and user confirmations.  

---

## 🧩 Tech Stack

- **Shell Scripting (Bash)**  
- **Zenity (GTK-based GUI)**  
- **Linux system utilities** — `top`, `free`, `df`, `find`, `bc`, `awk`

---

## ⚙️ Installation

1. Make sure you are on **Ubuntu/Linux**.  
2. Install Zenity if not already installed:
   ```bash
   sudo apt update
   sudo apt install zenity -y

