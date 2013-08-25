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

# programs.each do |p|
# 	p.explode! 
# 	p.get_functions
# end
programs[0].functions.each do |key,value| 
	puts "Key: #{key} Value: #{value} Signature #{programs[0].get_signature(key)}"

end

#puts programs[0].code
#Get the names of every function


#We analyze every line of each program
#to get the number of variables



# programs.each do |p|
# 	p.code.each do |line| 
# 		puts "<<<<" 
# 		line.each do |l|
# 			puts "\t #{l}"
# 		end
# 		puts ">>>> "
# 	end
# 	puts "====="
# end



