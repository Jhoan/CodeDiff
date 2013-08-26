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
print " "
print "=" * 71
print "\n"
print "|"
print "\t" * 4
print "Metric"
print "\t" * ((50-24)/4).ceil
print "\t |"
print "\tA\t|\tB\t| |A-B| |"
print "\n"
print " "
print "="*71
print "\n"
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

# print first_program_functions
# print "\n"
# print second_program_functions
# print "\n\n\n\n"
# print all_functions


# all_functions.each do |key|
# 	var_name = key.name
# 	key.countA = 0
# 	key.callsA = 0
# 	if programs[0].functions.has_key? var_name then
# 		key.countA += programs[0].vars[var_name]
# 	end
# 	key.countB = 0	
# 	if programs[1].vars.has_key? var_name then
# 		key.countB += programs[1].vars[var_name]
# 	end
# end



# prints vars
# count = 0
# programs.each do |program|
# 	puts "---Program #{count}"
# 	count += 1
# 	puts "\tFunctions: "
# 	program.functions.each do |key,value| 
# 		puts "Name: #{key} Count: #{value} Signature: #{program.get_signature(key)}"
# 	end
	# puts "\tVariables: "
	# program.vars.each do |key,value|
	# 	puts "Type: #{key} Count: #{value}"
	# end
# 	puts "\tDefines: "
# 	 #print program.defines
# 	program.defines.each do |key,value|
# 		puts "Type: #{key[0]} Count: #{value} Definition: #{key[1]}"
# 	end

# 	puts "\tIncludes: "
# 	program.headers.each do |item|
# 		puts "\t\t#{item}"
# 	end

# 	puts "\tLoops: "
# 	program.loops.each do |key,value|
# 		puts "\t\t#{key}: #{value}"
# 	end

# 	puts "\tCOnditionals: "
# 	program.conditionals.each do |key,value|
# 		puts "#\t\t#{key}: #{value}"
# 	end
# end






#Var Report
print " "
print "=" * 71
print "\n"
print "|"
print "\t" * 4
print "Variables"
print "\t" * ((71-24)/4).ceil
print "\t|"
print "\n"
print "|"
print "-"*71
print "|\n"
all_vars.each do |key|
	size = key.name.size + 1 #plus the first pipe
	tabs = ((50-size)/4).ceil
	puts "|#{key.name} " +"\t"*tabs+ " |\t#{key.countA}\t|\t#{key.countB}\t|\t#{(key.countA-key.countB).abs}\t|"
	print "|"
	print "-"*71
	print "|\n"
end
#count = 0
#print code
# programs.each do |program|
# 	puts "==Program: #{count}=="
# 	program.code.each do |block| 
# 		block.each do |line| 
# 		 	print "\t" +line 

# 			case programs[0].is_var?(line)
# 			when true
# 				print "\t--Variable\n"
# 			when false 
# 				print"\t--Function\n"
# 			when nil 
# 				print "\n"
# 			end
# 		end
# 	end
		
	
# 	count += 1
# end

#Count the functions
# program_index = 0
# block_index = 0
# line_index = 0
# programs.each do |program|
# 	block_index = 0
# 	program.code.each do |block|
# 		if block_index == 0 then #never compare the first block of a program STRUCT killer
# 			block_index += 1
# 			next
# 		end
# 		line_index = 0
# 		block.each do |line|
# 			program.functions.each do |function,count|
# 				print "Line: #{line} Function: #{function} "
# 				if line_index == 0 then #never compare the first line of a block
# 					line_index += 1
# 					break
# 				end
# 				if line.gsub(" ","").include? function+"(" then
# 					programs[program_index].functions[function] = count + 1

# 				end
# 				puts " Count: #{programs[program_index].functions[function]}\n"
# 				line_index+=1
# 			end
# 		end
# 		block_index += 1
# 	end
# 	program_index += 1
# 	count += 1
# end


#Print the signatures and vars
# count = 0
# programs.each do |program|
# 	puts "---Program #{count}"
# 	count += 1
# 	puts "\tFunctions: "
# 	program.functions.each do |key,value| 
# 		puts "Name: #{key} Count: #{value} Signature: #{program.get_signature(key)}"
# 	end
# 	#puts program.vars
# 	puts "\tVariables: "
# 	program.vars.each do |key,value|
# 		puts "Type: #{key} Count: #{value}"
# 	end
# 	puts "\tDefines: "
# 	 #print program.defines
# 	program.defines.each do |key,value|
# 		puts "Type: #{key[0]} Count: #{value} Definition: #{key[1]}"
# 	end

# 	puts "\tIncludes: "
# 	program.headers.each do |item|
# 		puts "\t\t#{item}"
# 	end

# 	puts "\tLoops: "
# 	program.loops.each do |key,value|
# 		puts "\t\t#{key}: #{value}"
# 	end

# 	puts "\tCOnditionals: "
# 	program.conditionals.each do |key,value|
# 		puts "#\t\t#{key}: #{value}"
# 	end
# end

#Print vars

