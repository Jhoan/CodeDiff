#main calls of CodeDiff

files = Array.new()
next_file = String.new()
raise ArgumentError, "Two filenames expected." unless ARGV.size == 2
#We make sure we can read the files 
begin
	ARGV.each  do |arg|
		next_file = arg
		File.open(arg,"r") do |file| 
			files.push(file.read) 
			file.close
		end
	end
rescue 
	puts "Can not read the file #{next_file}"
	abort()
end


#Now we split the contents of the files into
#arrays, using semicolons and new lines as delimiters.
files.size.times do |i|
	files[i] = files[i].gsub(";", "\n").split("\n").map(&:strip).reject(&:empty?)
end

	programs = Array.new() #this will contain the programs

#For further analysis we create an object for every file
#this, also, will extract all the information needed.
begin
	files.each { |file|  programs.push(Program.new(file))}
rescue
	puts "FATAL ERROR: It is recommended that you compile 
	your code (using the -ANSI and -pedantic flags)
	before executing this program. If you already did that then... 
	well... I'm afraid you encountered a bug :("
	abort()
end

all_vars = Array.new()
#Variables Report:
#Recover all distinct variables
programs.each do |program|
	program.vars.each_key do |var|
		temp = OpenStruct.new
		temp.name = var
		all_vars.push(temp) unless all_vars.include? temp 
	end
end
#count each var
all_vars.each do |key|
	var_name = key.name
	key.countA = 0
	if programs[0].vars.has_key? var_name then
		key.countA += programs[0].vars[var_name]
	end
	key.countB = 0	
	if programs[1].vars.has_key? var_name then
		key.countB += programs[1].vars[var_name]
	end
end
#Functions report
#Extract all signatures

first_program_functions = Array.new()
programs[0].functions.each do |var,calls|
	found_index = -1
	index = 0
	signature = programs[0].get_signature(var)
	temp = OpenStruct.new
	temp.name = signature
	temp.count = 1
	temp.calls = calls
	first_program_functions.each do |f| #find duplicate
		if f.name == temp.name then
			found_index = index
			break
		end
		index += 1
	end
	if found_index < 0 then #new function 
		first_program_functions.push(temp)
	else #add count
		first_program_functions[found_index].count += 1
		first_program_functions[found_index].calls += calls
	end
end

second_program_functions = Array.new()
programs[1].functions.each do |var,calls|
	found_index = -1
	index = 0
	signature = programs[1].get_signature(var)
	temp = OpenStruct.new
	temp.name = signature
	temp.count = 1
	temp.calls = calls
	second_program_functions.each do |f| #find duplicate
		if f.name == temp.name then
			found_index = index
			break
		end
		index += 1
	end
	if found_index < 0 then #new function 
		second_program_functions.push(temp)
	else #add count
		second_program_functions[found_index].count += 1
		second_program_functions[found_index].calls += calls
	end
end

#merge functions
all_functions = Array.new
first_program_functions.each do |f|
	all_functions.push(f)
end

second_program_functions.each do |second_f|
	sig = second_f.name
	index_found = -1
	index = 0
	all_functions.each do |existing_f| #find duplicates
		if sig == existing_f.name then
			index_found = index
			break
		end
		index += 1
	end
	if index_found < 0 then #not duplicate
		temp = OpenStruct.new
		temp.name = sig
		temp.countB = second_f.count 
		temp.callsB = second_f.calls
		temp.count = 0
		temp.calls = 0
		all_functions.push(temp)
	else
		all_functions[index_found].countB = second_f.count
		all_functions[index_found].callsB = second_f.calls
	end

end

#extract defines 

all_defines = Array.new
programs[0].defines.each do |key, value|
	temp = OpenStruct.new
	if key[1].include? "(" then
		temp.name = key[1]
	else
		temp.name = key[0]
	end
	temp.count = 1
	temp.calls = value
	all_defines.push(temp)
end

programs[1].defines.each do |key,value|
	if key[1].include? "(" then
		new_name = key[1]
	else
		new_name = key[0]
	end

	index_found = -1
	index = 0
	all_defines.each do |existing_name| #find duplicates
		if new_name == existing_name.name then
			index_found = index
			break
		end
		index += 1
	end
	if index_found < 0 then #not duplicate
		temp = OpenStruct.new
		temp.name = new_name
		temp.countB = 1
		temp.callsB = value
		temp.count = 0
		temp.calls = 0
		all_defines.push(temp)
	else
		all_defines[index_found].countB = 1
		all_defines[index_found].callsB = value
	end

end

#Headers Report:
all_headers = Array.new()

#Recover all distinct variables
programs.each do |program|
	program.headers.each do |var|
		temp = OpenStruct.new
		temp.name = var
		all_headers.push(temp) unless all_headers.include? temp 
	end
end
#count each var
all_headers.each do |key|
	var_name = key.name
	key.countA = 0
	if programs[0].headers.include? var_name then
		key.countA = 1
	end
	key.countB = 0	
	if programs[1].headers.include? var_name then
		key.countB += 1
	end
end

#loops and conditionals
all_control_structures = Array.new


if programs[0].if > 0 || programs[1].if  > 0
	temp = OpenStruct.new
	temp.name = "if"
	temp.countA = programs[0].if > 0 ? programs[0].if : 0
	temp.countB = programs[1].if > 0 ? programs[1].if : 0
	all_control_structures.push(temp)
end
if programs[0].for > 0 || programs[1].for > 0
	temp = OpenStruct.new
	temp.name = "for"
	temp.countA = programs[0].for > 0 ? programs[0].for : 0
	temp.countB = programs[1].for > 0 ? programs[1].for : 0
	all_control_structures.push(temp)
end
if programs[0].while > 0 || programs[1].while > 0
	temp = OpenStruct.new
	temp.name = "while"
	temp.countA = programs[0].while > 0 ? programs[0].while : 0
	temp.countB = programs[1].while > 0 ? programs[1].while : 0
	all_control_structures.push(temp)
end
if programs[0].switch > 0 || programs[1].switch  > 0
	temp = OpenStruct.new
	temp.name = "switch"
	temp.countA = programs[0].switch > 0 ? programs[0].switch : 0
	temp.countB = programs[1].switch > 0 ? programs[1].switch : 0
	all_control_structures.push(temp)
end


#Report Header
print " "
print "=" * 112 #112
print "\n"
print "|"
print "\t" * 4
print "Metric"
print "\t" * ((112-24)/4).ceil
print "\t|"

print "\n"
print " "
print "="*112
print "\n"


#Var Report
print " "
print "=" * 112
print "\n"
print "|"
print "\t" * 4
print "Variables"
print "\t" * ((112-24)/4).ceil
print "|"
print "\n"
print "|"
print "-"*111
print "|\n"
all_vars.each do |key|
	size = key.name.size + 1 #plus the first pipe
	tabs = ((90-size)/4).ceil
	if tabs > 0 then
		print "|#{key.name} " +"\t"*tabs
	else
		if size > 63 then
			print "|#{key.name.slice(0,60)} " + " " * 50 +"|\n"
			print "|\t#{key.name.slice(60,key.name.size-60)}"
			spaces = 90 - (key.name.size - 60) - 6
			print " " * spaces
		else
			spaces = 63 - size
			print "|#{key.name}" + " "*spaces
		end
	end
	print "|\t#{key.countA}\t|\t#{key.countB}\t|\t#{(key.countA-key.countB).abs}\t|"
	print "\n|"
	print "-"*111
	print "|\n"
end

#Function Report
print " "
print "=" * 112
print "\n"
print "|"
print "\t" * 4
print "Functions"
print "\t" * ((112-24)/4).ceil
print "|"
print "\n"
print "|"
print "-"*111
print "|\n"

all_functions.each do |key|
	size = key.name.size + 1 #plus the first pipe
	tabs = ((90-size)/4).ceil
	if tabs > 0 then
		print "|#{key.name} " +"\t"*tabs
	else
		if size > 63 then
			print "|#{key.name.slice(0,60)} " + " " * 50 +"|\n"
			print "|\t#{key.name.slice(60,key.name.size-60)}"
			spaces = 90 - (key.name.size - 60) - 6
			print " " *spaces

		else
			spaces = 63 - size
			print "|#{key.name}" + " "*spaces
		end
	end
	print " |#{key.count}| #{key.calls}  |#{key.countB}| #{key.callsB}   |#{(key.count-key.countB).abs}| #{(key.calls-key.callsB).abs}   |"
	print "\n|"	
	print "-"*111
	print "|\n"
end

#Defines Report
print " "
print "=" * 112
print "\n"
print "|"
print "\t" * 4
print "Defines  "
print "\t" * ((112-24)/4).ceil
print "|"
print "\n"
print "|"
print "-"*111
print "|\n"

all_defines.each do |key|
	size = key.name.size + 1 #plus the first pipe
	tabs = ((90-size)/4).ceil
	if tabs > 0 then
		print "|#{key.name} " +"\t"*tabs
	else
		if size > 63 then
			print "|#{key.name.slice(0,60)} " + " " * 50 +"|\n"
			print "|\t#{key.name.slice(60,key.name.size-60)}"
			spaces = 90 - (key.name.size - 60) - 6
			print " " *spaces

		else
			spaces = 63 - size
			print "|#{key.name}" + " "*spaces
		end
	end
	print " |#{key.count}| #{key.calls}  |#{key.countB}| #{key.callsB}   |#{(key.count-key.countB).abs}| #{(key.calls-key.callsB).abs}   |"
	print "\n|"	
	print "-"*111
	print "|\n"
end

#Header Report
print " "
print "=" * 112
print "\n"
print "|"
print "\t" * 4
print "Headers  "
print "\t" * ((112-24)/4).ceil
print "|"
print "\n"
print "|"
print "-"*111
print "|\n"
all_headers.each do |key|
	size = key.name.size + 1 #plus the first pipe
	tabs = ((90-size)/4).ceil
	if tabs > 0 then
		print "|#{key.name} " +"\t"*tabs
	else
		if size > 63 then
			print "|#{key.name.slice(0,60)} " + " " * 50 +"|\n"
			print "|\t#{key.name.slice(60,key.name.size-60)}"
			spaces = 90 - (key.name.size - 60) - 6
			print " " * spaces
		else
			spaces = 63 - size
			print "|#{key.name}" + " "*spaces
		end
	end
	print "|\t#{key.countA}\t|\t#{key.countB}\t|\t#{(key.countA-key.countB).abs}\t|"
	print "\n|"
	print "-"*111
	print "|\n"
end

#Control Strunctures Report
print " "
print "=" * 112
print "\n"
print "|"
print "\t" * 4
print "Other    "
print "\t" * ((112-24)/4).ceil
print "|"
print "\n"
print "|"
print "-"*111
print "|\n"

index = 0
all_control_structures.each do |key|
	print "|#{key.name}"
	print "\t"*21 + "|\t#{key.countA}\t|\t#{key.countB}\t|\t#{(key.countA-key.countB).abs}\t|"
	print "\n|"
	print "-"*111
	print "|\n"
	index += 1
end

#footer
counts = 0
calls = 0
all_functions.each do |key|
	counts += (key.count-key.countB).abs
	calls += (key.calls-key.callsB).abs
end
all_defines.each do |key|
	counts += (key.count-key.countB).abs
	calls += (key.calls-key.callsB).abs
end
all_vars.each do |key|
	calls += (key.countA-key.countB).abs
end
all_headers.each do |key|
	calls += (key.countA-key.countB).abs
end
all_control_structures.each do |key|
	calls += (key.countA-key.countB).abs
end

print "\t" * 23 + "Subtotal: \t|#{counts}|\t#{calls}\t|"

