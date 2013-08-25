#!/usr/bin/env ruby

#Class function

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
	def get_type(line) #returns the name of a function
		raise ArgumentError, "Expected a String but got #{line.class.name} instead" unless line.is_a? String
		specifier = Array.new(["signed", "unsigned","short","const", "volatile"])
		type = Array.new(["void","long","char","int","float","double"])
		#raise ArgumentError, "Expected a function but got #{line} instead" unless is_var(line) == false
		declarations = specifier + type
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

		#create hash containing type=>0
		output = Hash.new(0)
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
		return output
	end

	def add_to_hash(hash,key)
		if hash.has_key? key then
			hash[key] += 1
		else
			hash[key] = 1
		end
	end

line =  "unsigned long int **ff,*o,i,d,l[2],(*pp)[M],pp[][]"
print "OUTPUT: "
puts get_type(line)

puts "**** #{clean_function(line)}"
