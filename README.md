# VLSI_TCL
TCL Workshop: From Introduction to Advanced Scripting Techniques in VLSI

**Introduction:**
TCL is widely used in VLSI industry for processing synthesis results, timing reports, automate the physical design flow such as floorplan, placement, and routing. All the EDA tools used in the VLSI industry are based on TCL and therefore, TCL scripting play a significant role in automating these processes that aides in improving the efficiency of the chip design flow, and quality of results. Therefore, TCL helps VLSI engineers to enhance productivity, increase efficiency, and automate the work flows.

**Table of Contents**

1. DAY 1 - Inception of the TCL worksop\n
   a. VLSI Design flow and application of TCL scripting\n
   b. Description of the tasks\n
   c. Introduction to Bash script\n

# DAY 1 - Inception of the TCL workshop

It serves as the foundation of the TCL scripting and the instructor introduced the set of tasks to be completed for the next 5 days. The instructor explained the VLSI flow and application of the TCL scripting in various parts of VLSI design flow. The instructor explained the task to be performed in the 5 day workshop. The task is to convert the constraints in csv format to SDC format, pass the SDC file to the synthesis tool YOSYS and run synthesis, parse the synthesis report to look for errors, and timing information. The next task is to convert the synthesis constraints to STA constraints format that is accepted by OpenTimer STA tool and run STA to analyze timing.

The initial task is to create a bash script to accept the argument i.e. csv file, and invoke TCL script that processes the csv file.

The bash script covers following scenarios:

a. No argument provided - when argument is not provided the bash script provides information to the user to provide the csv file

![image](https://github.com/KunalD09/VLSI_TCL/assets/18254670/dd7073fa-f15e-441d-8e3a-a8b7f1a40179)


b. Incorrect argument provided - when incorrect argument is provided, the bash script errors out displaying the message "Incorrect csv file provided"

![image](https://github.com/KunalD09/VLSI_TCL/assets/18254670/7bdec94a-ab59-4453-a387-0623db4b1793)


c. -help argument - when "-help" argument is provided, the script provides usage information

![image](https://github.com/KunalD09/VLSI_TCL/assets/18254670/c5f20612-693e-4570-86da-2a931478b29f)


d. Correct argument provided - when the bash script is provided with the correct CSV file argument, it forwards the CSV file to the TCL script for further processing.

![image](https://github.com/KunalD09/VLSI_TCL/assets/18254670/d030ea61-80b3-4e80-b9e3-8a002670fd57)


# Day 2 - Variable creation and processing constraints from CSV file





