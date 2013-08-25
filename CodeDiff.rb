#!/usr/bin/env ruby

#Class function
#Class: Program
class Program
	specifier = Array.new(["signed", "unsigned","short","const", "volatile"])
	type = Array.new(["void","long","char","int","float","double"])
	attr_reader :code
	#We'll store the ocurrences in hashes: Name=>Count
	@code = Array.new()
	@headers = Hash.new() 
	@defines = Hash.new()
	@functions = Hash.new(0) 
	@vars = Hash.new() #Main variables only
	def initialize(new_code)
		raise ArgumentError, "Expected Array but got #{new_code.class.name}" unless new_code.kind_of? Array
		@code = new_code

	end


	def get_functions(code) #Returns an array with the function signatures in the code
		@code.each do |line|
			
		end
	
	end
	#Converts an array containing code into an array of arrays 
	#where every inner array is one block of code
	def explode! 
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


#Returns true if a line of code is a variable declaration, false if it is a function or nil in any other case
def is_var?(line) 

	raise ArgumentError, "Expected String but got #{line.class.name} instead" unless line.is_a? String
	#specifier = Array.new(["signed", "unsigned","short","const", "volatile"])
	#type = Array.new(["void","long","char","int","float","double"])

	tokens = line.gsub(" ", ",").gsub("(", ",").gsub(")",",").split(",").map(&:strip).reject(&:empty?)
	type_matches = 0
	spec_matches = 0
	tokens.each do |token|
		if type.include? token then
			type_matches += 1
		end
		if specifier.include? token then
			spec_matches += 1
		end
	end
	return false if type_matches > 1
	return true if spec_matches >= 0 && type_matches == 1
	return nil
end

def get_name(line) #returns the name of a function
	specifier = Array.new(["signed", "unsigned","short","const", "volatile"])
	type = Array.new(["void","long","char","int","float","double"])
	raise ArgumentError, "Expected a String but got #{line.class.name} instead" unless line.is_a? String
	#raise ArgumentError, "Expected a function but got #{line} instead" unless is_var(line) == false
	declarations = specifier + type
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
def get_vars(function) #Get the variables of a function

end

	private :get_name 
	private :get_vars
	private :is_var?

end

#common methods




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

#puts programs[0].code
#Get the names of every function


#We analyze every line of each program
#to get the number of variables



programs.each do |p|
	p.code.each do |line| 
		puts "<<<<" 
		line.each do |l|
			puts "\t #{l}"
		end
		puts ">>>> "
	end
	puts "====="
end



