# VLSI_TCL
TCL Workshop: From Introduction to Advanced Scripting Techniques in VLSI

**Introduction:**
TCL is widely used in VLSI industry for processing synthesis results, timing reports, automate the physical design flow such as floorplan, placement, and routing. All the EDA tools used in the VLSI industry are based on TCL and therefore, TCL scripting play a significant role in automating these processes that aides in improving the efficiency of the chip design flow, and quality of results. Therefore, TCL helps VLSI engineers to enhance productivity, increase efficiency, and automate the work flows.

**Table of Contents**

1. DAY 1: Inception of the TCL worksop <br />
   a. VLSI Design flow and application of TCL scripting <br />
   b. Description of the tasks <br />
   c. Introduction to Bash script <br />

# DAY 1: Inception of the TCL workshop

It serves as the foundation of the TCL scripting and the instructor introduced the set of tasks to be completed for the next 5 days. The instructor explained the VLSI flow and application of the TCL scripting in various parts of VLSI design flow. The instructor explained the task to be performed in the 5 day workshop. The task is to convert the constraints in csv format to SDC format, pass the SDC file to the synthesis tool YOSYS and run synthesis, parse the synthesis report to look for errors, and timing information. The next task is to convert the synthesis constraints to STA constraints format that is accepted by OpenTimer STA tool and run STA to analyze timing.

The initial task is to create a bash script to accept the argument i.e. csv file, and invoke TCL script that processes the csv file.

**Bash script used for automation:**

#!/bin/tcsh -f

echo "\n"
echo "##########################################################################"
echo "######            ##############       #############  ####################"
echo "###########  #################  ####################  ####################"
echo "###########  ################  #####################  ####################"
echo "###########  ###############  ######################  ####################"
echo "###########  ###############  ######################  ####################"
echo "###########  ###############  ######################  ####################"
echo "###########  ################  #####################  ####################"
echo "###########  ##################  ###################  ####################"
echo "###########  ###################       #############         #############"
echo "##########################################################################"

set my_work_dir = 'pwd'

echo "\n\n"
#-----------------------------------------------------------------------------------------------
#-------------------------------------- Tool Initialization ------------------------------------
#-----------------------------------------------------------------------------------------------

if ($#argv != 1) then
	echo "Info: Please provide the csv file. Exiting..."
	exit 1
endif

if (! -f $argv[1] || $argv[1] == "-help") then
	if ($argv[1] != "-help") then
		echo "Error: Cannot find the csv file $argv[1]. Exiting..."
		exit 1
	else
		echo "USAGE: ./vsdsynth <filename.csv>"
		echo "\nProvide the correct csv file that contains the design name, netlist directory, constraints directory, library directory and output directory. Exiting..."	
		exit 1
	endif
else
	tclsh vsdsynth.tcl $argv[1]
endif 
echo "\n"


The bash script covers following scenarios:

a. No argument provided - when argument is not provided the bash script provides information to the user to provide the csv file

![image](https://github.com/KunalD09/VLSI_TCL/assets/18254670/dd7073fa-f15e-441d-8e3a-a8b7f1a40179)


b. Incorrect argument provided - when incorrect argument is provided, the bash script errors out displaying the message "Incorrect csv file provided"

![image](https://github.com/KunalD09/VLSI_TCL/assets/18254670/7bdec94a-ab59-4453-a387-0623db4b1793)


c. -help argument - when "-help" argument is provided, the script provides usage information

![image](https://github.com/KunalD09/VLSI_TCL/assets/18254670/c5f20612-693e-4570-86da-2a931478b29f)


d. Correct argument provided - when the bash script is provided with the correct CSV file argument, it forwards the CSV file to the TCL script for further processing.

![image](https://github.com/KunalD09/VLSI_TCL/assets/18254670/d030ea61-80b3-4e80-b9e3-8a002670fd57)


# DAY 2: Variable creation and processing constraints from CSV file

Contents of the csv file:

![image](https://github.com/KunalD09/VLSI_TCL/assets/18254670/eb34e1b1-855b-4180-adfb-b733e838b787)

As shown in the figure, the csv file consists of design name, file name and directory name, so it is crucial to extract the information from the csv file and use it to locate the design files, constraints file, and library files.

Therefore, for Day 2, the task is to create the variables and check whether the directories and files mentioned in csv file exists or not. 

TCL script is available in the repository for reference.

Following is the output of the TCL script:

1. Creating Variables from the csv file:

![image](https://github.com/KunalD09/VLSI_TCL/assets/18254670/d576983e-e0e5-470b-9336-80cd93fb04c1)

2. Checking the directory and files exists or not

![image](https://github.com/KunalD09/VLSI_TCL/assets/18254670/d9102d09-0684-4b6c-b36d-23e7eeaae397)


# DAY 3: Clock and Input constraints

On this day, the task was to convert the constraints provided in csv format to SDC format.

1. The terminal log shows the steps followed by the TCL script

![image](https://github.com/KunalD09/VLSI_TCL/assets/18254670/eb9c8a2c-7608-4fa2-a9bf-936b973f9287)


2. The result is stored in the sdc file as shown in the image below

![image](https://github.com/KunalD09/VLSI_TCL/assets/18254670/e9c71184-42fd-4a45-a8f0-79811956a56a)

# DAY 4: Constraints scripting and Introduction to Synthesis scripting












