Author: Jhoan Eduardo García Cruz
CodeDiff
========
A ruby implementation of an ANSI C code analyzer. 

Requirements:

	This program requires ruby 1.9.3 or better.
		To install it just run $sudo pacman -S ruby.
		Alternatively, open the folder "ruby" and run the install script.

Usage:

	1. Run the "$make" command.
	2. Run $./CodeDiff.rb "file1" "file2" > "output.txt".
	3. Open the file "output.txt" with your favorite text editor
	4. For a proper visualization of the data the tab width must be set to 4.
	Note: The file /src/header.rb contains the line "#!/usr/bin/env ruby" 
	      you may want to modify this depending on your system configuration. 
	You can also delete this line and run "$ruby ./CodeDiff.rb file1.c file2.c > output.txt" instead.


Additional info:

	Two test files have been included, both are located in the folder test_files, 
		 it is recommended that you open those files to see some of the program's  features. 
		 Please note that those files were made for test purposes only.


Known Bugs:

	Odd results.
		When initializing variables at the same time they are declared:
			Line in "int a=2;b=3".
		When a function with no arguments does not have the void keyword:
			"int foo();" will produce some unexpected results since "foo()"
			and "foo(void)" are NOT the same. See the ANSI C documentation for details.

	
	Crashes.
		When a function returns a pointer, the program may or may not complete its execution: 
			For example: "void **foo(int a)" may produce a crash.

	Additionally, any declaration of structs, enums and/or unions will produce unexpected behaviour.


Finally, this program is released under the MIT license. See details in the LICENSE file.


