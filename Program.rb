#Class: Program
class Program
	specifier = Array.new(["signed", "unsigned","short","const", "volatile"])
	type = Array.new(["void","long","char","int","float","double"])
	
	def initialize(new_code)
		raise ArgumentError, "Expected Array but got #{new_code.class.name}" unless new_code.kind_of? Array
		@code = new_code
		#We'll store the ocurrences in hashes: Name=>Count
		#@code = Array.new()
		@headers = Hash.new() 
		@defines = Hash.new()
		@functions = Hash.new(0) 
		@vars = Hash.new() #Main variables only
	end


	def get_functions() #Extract the functions from @code
		@code.each do |block|
			next unless block.first.include? "(" #skip structs
			name = get_name(block.first)
			@functions[name] = 0 unless @functions.has_key? name
		end
	end

	def get_signature(name) #Returns the signature of a given function

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
		raise ArgumentError, "Expected a String but got #{line.class.name} instead" unless line.is_a? String
		specifier = Array.new(["signed", "unsigned","short","const", "volatile"])
		type = Array.new(["void","long","char","int","float","double"])
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
	def get_vars(function) #Get the variables of a function
	end
		attr_reader :code
		attr_reader :functions
		private :get_name 
		private :get_vars
		private :is_var?

end

