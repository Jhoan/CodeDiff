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
	Report.make_report(programs)
rescue
	puts "\n\n*******FATAL ERROR: It is recommended that you compile 
	your code (using the -ANSI and -pedantic flags)
	before executing this program. If you already did that then... 
	well... I'm afraid you encountered a bug :("
	abort()
end



