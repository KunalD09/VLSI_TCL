puts "Hello Everyone\n"



package require csv
package require struct::matrix
struct::matrix m

set filename [lindex $argv 0]

puts "CSV file received by TCL script - $filename"
return

set f [open $filename]

# below command is used for converting the csv file to matrix, where auto isused for automatically figuring out the number of columns and rows
# In TCL, matrix is called using m(columns,rows)
csv::read2matrix $f m , auto

close $f

# below command will provide the number of columns to variable columns
set columns [m columns]
puts "Number of Columns = $columns"


# since we already know the number of columns, below command is not required
# m add columns $columns

# below command is used for creating an array with the name my_arr.
m link my_arr 

set num_of_rows [m rows]
puts "Number of Rows = $num_of_rows\n\n"

set i 0

# Autocreating the variables from the csv file
while {$i < $num_of_rows} {
	puts ":Info Setting $my_arr(0,$i) as $my_arr(1,$i)"
	set name [string map {" " ""} [string tolower $my_arr(0,$i)]] 
	if {$name == "designname"} {
		#set name [string map {" " ""} [string tolower $my_arr(0,$i)]] 
		set $name $my_arr(1,$i)
		puts "$name = $my_arr(1,$i)\n"
	} else {
		#set name [string map {" " ""} [string tolower $my_arr(0,$i)]] 
		set $name [file normalize $my_arr(1,$i)]
		puts "$name = [file normalize $my_arr(1,$i)]\n"
	}
	set i [expr {$i+1}]
}

# Below section checks whether the directories and files exists or not 
if {![file isdirectory $outputdirectory]} {
	puts "Info: Cannot find the output directory $outputdirectory.\nCreating the output directory -> $outputdirectory\n"
	file mkdir $outputdirectory
} else {
	puts "Info: Found the Output Directory - $outputdirectory\n"
}

if {![file isdirectory $netlistdirectory]} {
	puts "Info: Cannot find the netlist directory $netlistdirectory. Exiting...\n"
	exit
} else {
	puts "Info: Found the Netlist Directory - $netlistdirectory\n"
}

if {![file exists $earlylibrarypath]} {
	puts "Info: Cannot find the early library file $earlylibrarypath. Exiting...\n"
	exit
} else {
	puts "Info: Found the early library file - $earlylibrarypath\n"
}

if {![file exists $latelibrarypath]} {
	puts "Info: Cannot find the late library file $latelibrarypath. Exiting...\n"
	exit
} else {
	puts "Info: Found the late library file - $latelibrarypath\n"
}

if {![file exists $constraintsfile]} {
	puts "Info: Cannot find the constraints file $constraintsfile. Exiting...\n"
	exit
} else {
	puts "Info: Found the constraints file - $constraintsfile\n"
}


# Constraints file creation
puts "-> Constraints file creation <-"
puts "\nDumping SDC constraints for $designname"
::struct::matrix constraints
set cons [open $constraintsfile]
csv::read2matrix $cons constraints , auto
close $cons
set number_of_rows [constraints rows]
puts "Number of rows in $constraintsfile = $number_of_rows"
set number_of_columns [constraints columns]
puts "Number of columns in $constraintsfile = $number_of_columns\n"

# Check row number for clocks and column number for IO delay and slew in constraints.csv file
set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
puts "Clock starting row = $clock_start"
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0] 0]
puts "Clock starting columns = $clock_start_column\n"

# Check row number for inputs section in constraints.csv file
set input_ports_start [lindex [lindex [constraints search all INPUTS] 0] 1]
puts "Input ports starting row = $input_ports_start\n"

# Check row number for output section in constraints.csv file
set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]
puts "Output ports starting row = $output_ports_start\n"

#--------------clock constraints--------------#
#----------clock latency constraints----------#

set clock_early_rise_delay [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_rise_delay] 0] 0]
set clock_early_fall_delay [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_fall_delay] 0] 0]
set clock_late_rise_delay [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_rise_delay] 0] 0]
set clock_late_fall_delay [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_fall_delay] 0] 0]

#----------clock transition constraints----------#

set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_rise_slew] 0] 0]
set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_fall_slew] 0] 0]
set clock_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_rise_slew] 0] 0]
set clock_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_fall_slew] 0] 0]

set sdc_file [open $outputdirectory/$designname.sdc "w"]
set i [expr {$clock_start+1}]
set end_of_ports [expr {$input_ports_start-1}]
puts "\nInfo-SDC: Working on clock constraints..."

while {$i < $end_of_ports} {
	puts "Working on clock -> [constraints get cell 0 $i]"
	puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell 0 $i] -period [constraints get cell 1 $i] -waveform \{0 [expr {[constraints get cell 1 $i]*[constraints get cell 2 $i]/100}]\} \[get_ports [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -rise -max [constraints get cell $clock_late_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -fall -max [constraints get cell $clock_late_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -early -rise [constraints get cell $clock_early_rise_delay $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -early -fall [constraints get cell $clock_early_fall_delay $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -late -rise [constraints get cell $clock_late_rise_delay $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -late -fall [constraints get cell $clock_late_fall_delay $i] \[get_clocks [constraints get cell 0 $i]\]\n"
	set i [expr {$i+1}]
}

#---------------------------------------------------------------#
#---------- create input delay and slew constraints ------------#
#---------------------------------------------------------------#

set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_rise_delay] 0] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_fall_delay] 0] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_rise_delay] 0] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_fall_delay] 0] 0]


set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_rise_slew] 0] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_fall_slew] 0] 0]
set input_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_rise_slew] 0] 0]
set input_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_fall_slew] 0] 0]

set related_clock [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] clocks] 0] 0]
set i [expr {$input_ports_start+1}]
set end_of_ports [expr {$output_ports_start-1}]
puts "\nInfo-SDC: Working on IO constraints...."
puts "\nInfo-SDC: Categorizing input ports as bits and bussed"

while {$i < $end_of_ports} {
	set netlist [glob -dir $netlistdirectory *.v]
	set tmp_file [open /tmp/1 w]
	foreach f $netlist {
		set fd [open $f]
		puts "reading file $f"
		while {[gets $fd line] != -1} {
			set pattern1 " [constraints get cell 0 $i]"
			if {[regexp -all -- $pattern1 $line]} {
				puts "pattern1 \"$pattern1\" found and matching line in verilog file \"$f\" is \"$line\""
				set pattern2 [lindex [split $line ";"] 0]
				puts "creating pattern2 by splitting pattern1 using semi-colon as delimiter => \"$pattern2\""
				if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {
					puts "out of all patterns, \"$pattern2\" has matching string \"input\". So preserving this line and ignoring others"
					set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
					puts "printing first 3 elements of pattern2 as \"$s1\" using space delimiter"
					puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
					puts "replace multiple spaces in s1 by single space and reformat as \"[regsub -all {\s+} $s1 " "]\""
				}
			}
		}
	close $fd
	}

close $tmp_file
set tmp_file [open /tmp/1 r]
set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]
set count [llength [read $tmp2_file]]
if {$count>2} {\
	set inp_ports [concat [constraints get cell 0 $i]*]
	puts "bussed"
} else {
	set inp_ports [constraints get cell 0 $i]
	puts "not bussed"
}
	puts "input port name is $inp_ports since count is $count\n"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_delay_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_delay_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_delay_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_delay_start $i] \[get_ports $inp_ports\]"

	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_slew_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_slew_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_slew_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_slew_start $i] \[get_ports $inp_ports\]"

	set i [expr {$i+1}]

}
close $tmp2_file


set i 0
#---------------------------------------------------------------#
#---------- create output delay and load constraints -----------#
#---------------------------------------------------------------#

set output_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] early_rise_delay] 0] 0]
set output_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] early_fall_delay] 0] 0]
set output_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] late_rise_delay] 0] 0]
set output_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] late_fall_delay] 0] 0]
set output_load_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] load] 0] 0]


set related_clock [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] clocks] 0] 0]
set i [expr {$output_ports_start+1}]
puts "i=$i"
set end_of_ports [expr {$number_of_rows-1}]
puts "end_of_ports = $end_of_ports"
puts "\nInfo-SDC: Working on IO constraints...."
puts "\nInfo-SDC: Categorizing output ports as bits and bussed"

while {$i < $end_of_ports} {
	set netlist [glob -dir $netlistdirectory *.v]
	set tmp_file [open /tmp/1 w]
	foreach f $netlist {
		set fd [open $f]
		puts "reading file $f"
		while {[gets $fd line] != -1} {
			set pattern1 " [constraints get cell 0 $i]"
			if {[regexp -all -- $pattern1 $line]} {
				puts "pattern1 \"$pattern1\" found and matching line in verilog file \"$f\" is \"$line\""
				set pattern2 [lindex [split $line ";"] 0]
				puts "creating pattern2 by splitting pattern1 using semi-colon as delimiter => \"$pattern2\""
				if {[regexp -all {output} [lindex [split $pattern2 "\S+"] 0]]} {
					puts "out of all patterns, \"$pattern2\" has matching string \"output\". So preserving this line and ignoring others"
					set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
					puts "printing first 3 elements of pattern2 as \"$s1\" using space delimiter"
					puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
					puts "replace multiple spaces in s1 by single space and reformat as \"[regsub -all {\s+} $s1 " "]\""
				}
			}
		}
	close $fd
	}

close $tmp_file
set tmp_file [open /tmp/1 r]
set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]
set count [llength [read $tmp2_file]]
if {$count>2} {\
	set op_ports [concat [constraints get cell 0 $i]*]
	puts "bussed"
} else {
	set op_ports [constraints get cell 0 $i]
	puts "not bussed"
}
	puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
	puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $output_early_fall_delay_start $i] \[get_ports $op_ports\]"
	puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $output_late_rise_delay_start $i] \[get_ports $op_ports\]"
	puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $output_late_fall_delay_start $i] \[get_ports $op_ports\]"
	puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i] \[get_ports $op_ports\]"

	set i [expr {$i+1}]
}
