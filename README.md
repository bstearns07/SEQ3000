# RPT 6000
![License](https://img.shields.io/badge/License-MIT-green)<br>

---

## 👤 Author
Ben Stearns - [@bstearns07](https://github.com/bstearns07)<br>
---

## 📑 Table of Contents
- [📌 Summary](#-summary)
- [✨ Features](#-features)
- [⚙️ How It Works](#how-it-works)
- [OLDEMP File Structure](#oldemp-file-structure)
- [NEWEMP File Structure](#newemp-file-structure)
- [EMPTRAN File Struture](#emptran-file-structure)
- [🧰 Tech Stack](#-tech-stack)
- [🧠 New Topics Covered](#-topics-covered)
- [📘 What I Learned](#-what-i-learned)
- [🖼 Screenshots](#-screenshots)

---

## 📌 Summary

Welcome the the SEQ3000 COBOL program. This is something different from all the other COBOL projects I've done so far. The overall
purpose of this program to show how you can utilize COBOL to add/edit/delete information in one file based on instrutions from another file.
Here we have 3 input data files and 1 error log file:
1. OLDEMP: represents to old data records without any updates made to them.
2. NEWEMP: represents the old file after add/edit/deletes have been made so you can see the change
3. EMPTRAN: the instruction on what changes to make (has intentially bad instructions to test that error logging works)
4. ERRTRAN3: displays any errors that occurred during the update process

For full program details, refer to [Program Requirements](./assets/Assignment_Instruction.pdf) 

---

## ✨ Features

- Demonstrates CRUD fuctions (create, read, update, delete) functions to update a file
- Error handling and logging if errors occurs during file update
- Conditional switches to control program flow
- Fixed-block records for data
- Record matching logic to properly match an old record with a transaction record
---

## How It Works

1. Upload the repository's associated .cbl, .jcl, and Input_Data files to your mainframe environment
2. Modify the DSN name of all files to match the filepath to where they are in your environment
3. Submit the JCL job for processing
4. You should see all changes made in the NEWEMP file while keep the old file unchanged for comparison

---

## OLDEMP File Structure


---
## NEWEMP File Structure


---
## EMPTRAN File Structure


---
## 🧰 Tech Stack

- Enterprise COBOL 6.4 (Semantic Markup)
- IBM z/OS mainframe for development and compiling
- ZOWE Explorer Studio Code extension

### 🛠 Development Tools
- Marist z/OS Mainframe environment
- Visual Studio Code with ZOWE Explorer extension

---

## 🧠 New Topics Covered

1. Adding, reading, updating, and delete records from a file
2. How to perform error handling when manipulating a file
---

## 📘 What I Learned

---

## 🖼 Screenshots
