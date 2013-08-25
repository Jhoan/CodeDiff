#Class: Program
class Program
	
	def initialize(new_code)
		raise ArgumentError, "Expected Array but got #{new_code.class.name}" unless new_code.kind_of? Array
		@specifier = Array.new(["signed", "unsigned","short","long","const", "volatile"])
		@type = Array.new(["void","char","int","float","double"])
		@code = new_code
		#We'll store the ocurrences in hashes: Name=>Count
		#@code = Array.new()
		@headers = Hash.new() 
		@defines = Hash.new()
		@functions = Hash.new(0) 
		@vars = Hash.new() #Main variables only
		@exploded = false
		self.get_functions()
		self.count_functions()
		self.set_vars()
	end

	def set_vars() #Extracts and counts the variables in @code
		output = Hash.new(0)
		self.explode! unless @exploded
		declarations = @specifier + @type
		@code.each do |block| 
			line_index = 0
			block.each do |line|
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
				puts line
				puts spec
				name = name.split(",")
				print "name: "
				print name
				print "\n"

				
				aux = line.gsub(spec,"").split(",")
				print "aux: "
				print aux
				print "\n"

				key = ""
				index = 0
				aux.each do |var|
					key = spec + var.gsub(name[index],"")
					puts "key: #{key}"
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
		return true if spec_matches >= 0 && type_matches == 1
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
		private :get_name 
		
		#private :is_var?


end

