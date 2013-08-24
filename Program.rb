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

