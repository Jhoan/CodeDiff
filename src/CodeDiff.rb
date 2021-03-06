#!/usr/bin/env ruby
require 'ostruct'

#Class: Program
class Program
	
	def initialize(new_code)
		raise ArgumentError, "Expected Array but got #{new_code.class.name}" unless new_code.kind_of? Array
		@specifier = Array.new(["signed", "unsigned","short","long","const", "volatile"])
		@type = Array.new(["void","char","int","float","double"])
		@code = new_code
		#We'll store the ocurrences in hashes: Name=>Count
		#@code = Array.new()
		@headers = Array.new(0)
		@defines = Hash.new()
		@functions = Hash.new(0) 
		@vars = Hash.new()
		@exploded = false
		#@loops = {:for => 0,:while => 0}
		#@conditionals = {:if => 0, :switch => 0}
		@for = 0
		@while = 0
		@if = 0
		@switch = 0

		self.get_functions()
		self.count_functions()
		self.set_vars()
		self.get_defines()
		self.count_defines()
		self.set_headers()
		self.set_control_structures()
	end

	def set_control_structures() #extracts and counts loops and conditionals
		@code.each do |block|
			block.each do |line|
				line = line.gsub(" ","")
				#puts "===#{line}"
				if line.start_with? "if(" then
					@if += 1
				elsif line.start_with? "switch(" then
					@switch += 1
				elsif line.start_with? "for(" then
					@for += 1
				elsif line.include? "while(" then
					@while += 1
				end
			end
		end
	end
	def set_headers()
		#theoretically, the #include directives can be placed anywhere in the code
		#but this program will only check in the first block because thats the convention
		@code[0].each do |line|
			if line.start_with? "#include" then
				#puts "====#{line}===="
				@headers.push(line[8..-1].strip)
			end
		end
		#print @headers
	end
	def get_defines()
		macro = ""
		flag = false
		output = {}
		@code.each do |block|
			flag = false
			block.each do |line|
				#puts "next: #{line}"
				#puts "last_char: #{line.strip[-1]}"
				if line.include?("#define") then
					if line.strip[-1] != "\\" then #single line macro
						temp = line.gsub("#define","").strip.split(" ",2)
						name = temp[0]
						definition = temp[1]
					else #multiline macro
						flag = true
						macro.concat(line.gsub("#define","") + " ")
					end
				elsif flag == true #reading macro
					if line.strip[-1] == "\\"
						macro.concat(line)
					else 
						flag = false #stop reading macro
						macro.concat(line)
						macro = macro.strip
						#puts "FINAL MACRO #{macro}"
						index_delimiter = macro.index("(")
						if macro.index(" ") < index_delimiter then
							index_delimiter = macro.index(" ")
						end
						name = macro.slice(0,index_delimiter)
						definition = macro
						
					end
				else
					#puts "else: #{line}"
					next
				end
				#puts "macro: #{macro}"
				if flag == false then
					temp = []
					temp.push(name)
					temp.push(definition.gsub("\\",""))
					output[temp] = -1
				end

			end
		end
		@defines = output
	end
	def count_defines() #Counts define calls
		@code.each do |block|
			line_index = 0
			block.each do |line|
				@defines.each do |key,value|
					if key[1].include? "(" then #macro
						if line.gsub(" ","").include? key[0] + "(" then
							@defines[key] += 1
						end
					else #constant
						if line.gsub(" ","").include? key[0] then
							@defines[key] += 1
						end
					end
				end
			end
		end
		# @defines.each do |key,value|
		# 	@defines[key] -= 1 #-1 because of the definition
		# 	#this allows a macro call inside another macro
		# end
	end
	def set_vars() #Extracts and counts the variables in @code
		output = Hash.new(0)
		self.explode! unless @exploded
		declarations = @specifier + @type
		skip = true
		
		@code.each_with_index do |block, i|	
			if i == 0 then #skip first block to avoid picking up a macro as a variable
				next 
			end
			line_index = 0
			block.each do |line|
				#puts line
				if is_var?(line) != true then #discard functions and code body
					next 
				end
				aux = line.gsub("*"," ").gsub("("," ").gsub(")"," ").split(" ")
				spec = ""
				name = ""
				flag = false
				aux.each do |token|
					if declarations.include? token then
						spec.concat(token+" ") 
					else
						token.each_char do |c|
							if c == "[" then flag = true end
							if flag == false then name.concat(c) end
							if c == "]" then flag = false end
						end
					end

				end
				#puts line
				#puts spec
				name = name.split(",")
				#print "name: "
				#print name
				#print "\n"

				
				aux = line.gsub(spec,"").split(",")
				#print "aux: "
				#print aux
				#print "\n"

				key = ""
				index = 0
				aux.each do |var|
					key = spec + var.gsub(name[index],"")
					#puts "key: #{key}"
					if key.include? "[" then
						key = clean_function(key)
					end
					add_to_hash(output,key.strip)
					index += 1
				end
				line_index += 1
			end
		end
		@vars = output 
	end

	def get_functions() #Extract the functions from @code
		self.explode! unless @exploded
		@code.each do |block|
			next unless block.first.include? "(" #skip structs
			name = get_name(block.first)
			@functions[name] = 0 unless @functions.has_key? name
		end
	end

	def count_functions() #Counts the function calls
		line_index = 0
		block_index = 0
		@code.each do |block|
			if block_index == 0 then #never compare the first block of a program STRUCT killer
				block_index += 1
				next
			end
			line_index = 0
			block.each do |line|
				@functions.each do |function,count|
					#print "Line: #{line} Function: #{function} "
					if line_index == 0 then #never compare the first line of a block
						line_index += 1
						break
					end
					if line.gsub(" ","").include? function+"(" then
						@functions[function] = count + 1
					end
					#puts " Count: #{programs[program_index].functions[function]}\n"
					line_index+=1
				end
			end
			block_index += 1
		end
	end
	def get_signature(function) #Returns the signature of a given function
		@code.each do |block|
			next unless block.first.include? "(" #skip structs
			name = get_name(block.first)
			if function.strip == name.strip
				output = []
				output = block.first.chomp('{').split("(",2)
				output[0] = output[0].gsub(name,"")
				temp = output[1].split(",") #split the args
				index = 1
				temp.each do |arg|
					if arg.include? "(" then
						#if its a pointer, then clean it
						output[index] = clean_function(arg).strip
					else
						#otherwise just get the name and chomp it
						output[index] = arg.chomp(get_name(arg)).strip
					end
					index += 1
				end
				formatted_output = ""
				index = 0
				output.each do |e|
					if index == 0 then
						formatted_output += "( " + e.strip + " ) "
					else
						if index == 1 then
							formatted_output += "( "
						end
						if index > 1 then
							formatted_output += ", "
						end
						formatted_output += e.strip == "" ? "void" : e.strip

					end
					index += 1
				end
				return formatted_output + " )"
			end
		end
		return nil
	end 

	#Converts an array containing code into an array of arrays 
	#where every inner array is one block of code
	def explode! 
		brace_count = 0
		index = 0
		output = Array.new
		output.push(Array.new)
		code.each do |current_line| 
			if current_line.include? "{" then
				brace_count+=1
				if brace_count == 1
					if current_line.strip == "{" 
						temp = output[index].pop
						output.push(Array.new)
						index+=1
						output[index].push(temp)
					else
						output.push(Array.new)
						index+=1
					end			
				end
			end	
		
			if current_line.include? "}"
				brace_count -= 1
			end
		
			output[index].push(current_line)
		end
		@exploded = true
		@code = output
	end


#Returns true if a line of code is a variable declaration, false if it is a function or nil in any other case
	def is_var?(line) 

		raise ArgumentError, "Expected String but got #{line.class.name} instead" unless line.is_a? String
		#In order to detect casting, a var can't contain "()" and "="
		flag = false
		if line.include? "(" 
			if line.include? "=" then
				flag = true
			end
		end
		tokens = line.gsub(" ", ",").gsub("(", ",").gsub(")",",").split(",").map(&:strip).reject(&:empty?)
		type_matches = 0
		spec_matches = 0
		
		tokens.each do |token|
			if @type.include? token then
				type_matches += 1
			end
			if @specifier.include? token then
				spec_matches += 1
			end
		end
		#print "TypeMatches: #{type_matches} SpecMatches: #{spec_matches}"
		return false if type_matches > 1
		return true if spec_matches >= 0 && type_matches == 1 && flag == false
		return nil
	end

	def get_name(line) #returns the name of a function
		raise ArgumentError, "Expected a String but got #{line.class.name} instead" unless line.is_a? String
		# @specifier = Array.new(["signed", "unsigned","short","const", "volatile"])
		# @type = Array.new(["void","long","char","int","float","double"])
		#raise ArgumentError, "Expected a function but got #{line} instead" unless is_var(line) == false
		declarations = @specifier + @type
		aux = line.gsub("*"," ").split(" ")
		last_line = ""
		name = nil
		aux.each do |token|
			last_line = token
			if token.include? "(" then break end
			name = token unless declarations.include? token
		end
		if name.nil? then
			return last_line.slice(0,last_line.index("("))
		else
			return name
		end
	end

	def get_type(line) #returns the data type declaration of a variable
		name = get_name(line)
		return gsub(name,"")
	end

	def clean_function(line) #Removes everything but * inside parenthesis or brackets
		output =  ""
		flag = false
		line.each_char do |chr|  
			if chr == "(" || chr == "[" then
				flag = true
				output.concat(chr)
			end
			if chr == ")" || chr == "]" then
				flag = false
			end
			if flag == false then
				output.concat(chr)
			else
				output.concat(chr) if chr == "*" 
			end

		end
		return output
	end
	def add_to_hash(hash,key)
		if hash.has_key? key then
			hash[key] += 1
		else
			hash[key] = 1
		end
	end

		attr_reader :code
		attr_reader :functions
		attr_reader :vars
		attr_reader :defines
		attr_reader :headers
		attr_reader :if
		attr_reader :for
		attr_reader :while
		attr_reader :switch


end

#main calls of CodeDiff

files = Array.new()
next_file = String.new()
raise ArgumentError, "Two filenames expected." unless ARGV.size == 2
#We make sure we can read the files 
begin
	ARGV.each  do |arg|
		next_file = arg
		File.open(arg,"r") do |file| 
			#The following REGEX will remove any comments from the files
			files.push(file.read.gsub(/(\/\*([^*]|[\r\n]|(\*+([^*\/]|[\r\n])))*\*+\/)|(\/\/.*)/,"")) 
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
	size = key.name.size #plus the first pipe
	spaces = 87-size
	if spaces > 0 then
			print "|#{key.name} " +" "*spaces
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

print "\t" * 23 + "Subtotal: \t|#{counts}|\t#{calls}\t\n"
print "\t" * 20 + "Degree of Similarity:\t#{counts+calls}"