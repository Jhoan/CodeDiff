#main calls of CodeDiff

files = Array.new()
next_file = String.new()
raise ArgumentError, "Two filenames expected." unless ARGV.size >= 2
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
	puts "Can not read file #{next_file}"
	abort()
end


#Now we split the contents of the files into
#arrays, using semicolons and new lines as delimiters.
files.size.times do |i|
	files[i] = files[i].gsub(";", "\n").split("\n").map(&:strip).reject(&:empty?)
end



programs = Array.new() #this will contain the programs

#For further analysis we create an object for every file
files.each { |file|  programs.push(Program.new(file))}


count = 0
#print code
programs.each do |program|
	puts "==Program: #{count}=="
	program.code.each do |block| 
		block.each do |line| 
		 	print "\t" +line 

			case programs[0].is_var?(line)
			when true
				print "\t--Variable\n"
			when false 
				print"\t--Function\n"
			when nil 
				print "\n"
			end
		end
	end
		
	
	count += 1
end

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
count = 0
programs.each do |program|
	puts "---Program #{count}"
	count += 1
	puts "\tFunctions: "
	program.functions.each do |key,value| 
		puts "Name: #{key} Count: #{value} Signature: #{program.get_signature(key)}"
	end
	#puts program.vars
	puts "\tVariables: "
	program.vars.each do |key,value|
		puts "Type: #{key} Count: #{value}"
	end
	puts "\tDefines: "
	 #print program.defines
	program.defines.each do |key,value|
		puts "Type: #{key[0]} Count: #{value} Definition: #{key[1]}"
	end

	puts "\tIncludes: "
	program.headers.each do |item|
		puts "\t\t#{item}"
	end

	puts "\tLoops: "
	program.loops.each do |key,value|
		puts "\t\t#{key}: #{value}"
	end

	puts "\tCOnditionals: "
	program.conditionals.each do |key,value|
		puts "#\t\t#{key}: #{value}"
	end
end

#Print vars

