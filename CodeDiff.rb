#!/usr/bin/env ruby

#Class function
#Class: Program
class Program
	attr_reader :code
	#We'll store the ocurrences in hashes: Name=>Count
	@code = Array.new()
	@headers = Hash.new() 
	@defines = Hash.new()
	@functions = Hash.new() 
	@vars = Hash.new() #Main variables only
	def initialize(new_code)
		raise ArgumentError, "Expected Array but got #{new_code.class.name}" unless new_code.kind_of? Array
		@code = new_code
	end
	def explode! #Converts an array containing code into an array of arrays where every inner array is one level down
		brace_count = 0
		index = 0
		output = Array.new
		output.push(Array.new)
		@code.each do |current_line| 

			if current_line.include? "{" 
				brace_count+=1
				if brace_count == 1
					output.push(Array.new)
					index+=1
				end
			end	
		
			if current_line.include? "}"
				brace_count -= 1
			end
		
			output[index].push(current_line)
		end

		@code = output
	end

	def get_vars(function) #Get the variable declarations of a function
	end

end

#common methods

def is_var?(line) #return true if a line of code is a variable declaration
	raise ArgumentError, "Expected String but got #{line.class.name} instead" unless line.is_a? String
	specifier = Array.new(["void", "signed", "unsigned","short"])
	type = Array.new(["long","char","int","float","double"])

	tokens = line.split(" ")
	if specifier.include? tokens[0] 
		return true
	end
	if type.include? tokens[0] 
		return true
	end




	return false
end

#int foo(char);
#int foo(void)
#int 
#int a;#main calls of CodeDiff

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

programs.each do |p|
	p.explode!
end

programs.each do |p|
	p.code.each do |line| 
		puts "**** " 
		line.each { |l|  puts l if is_var? l }
		puts "**** "
	end
end

