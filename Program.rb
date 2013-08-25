#Class: Program
class Program
	specifier = Array.new(["signed", "unsigned","short","const", "volatile"])
	type = Array.new(["void","long","char","int","float","double"])
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


	def get_functions(code) #Returns an array with the function signatures in the code

	
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
	i = line.index("(")
	len = 0
	begin
		i-=1
		
		if line[i] == " " && len == 0 then
			begin
				i-=1 
			end until line[i] != " "
		end
		len+=1

	end until line[i] == " "
	return line.slice(i,len).strip

end
def get_vars(function) #Get the variables of a function

end

end

