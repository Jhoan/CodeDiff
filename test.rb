#This file is for testing purposes only
code = Array.new(["#include<stdio.h>",
				"float foo(int,char)",
				"int main(){",
					"int x=0","float y=3",
					"char *s",
					"for(){",
						"code",
						"do{",
							"more code",
						"}while",
						"yet more code",
						"foo(a,b)",
					"}",	
				"return 0",
				"}",
				"float foo(int n,char d)",
				"{",
					"code",
				"}"])


def is_var?(line) 
	raise ArgumentError, "Expected String but got #{line.class.name} instead" unless line.is_a? String
	specifier = Array.new(["signed", "unsigned","short","const", "volatile"])
	type = Array.new(["void","long","char","int","float","double"])

	
	tokens = line.gsub(" ", ",").gsub("(", ",").gsub(")",",").split(",").map(&:strip).reject(&:empty?)

	type_matches = 0
	spec_matches = 0
	# puts"<<"
	# tokens.each do |t|
	# 	puts t
	# end
	# puts ">>"
	

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

def explode!(code)
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

		return output
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

# line = " int foo(int a, float name, int (*a)[] )"
# output = []
# output = line.chomp('{').split("(",2)

# output[0] = output[0].gsub("foo","") #foo -> name

# temp = output[1].split(",")
# print output 
# print "\n"
# index = 1
# temp.each do |arg|
# 	if arg.include? "(" then
# 		output[index] = clean_function(arg).strip

# 	else
# 		#print get_name(arg) + "\n"
# 		output[index] = arg.gsub(get_name(arg),"")
# 	end
# 	index += 1
# end
# print output


# ep = explode!(code)
# puts code

# ep.each do |line|
# 	puts "<<"
# 	line.each { |e| puts "\t #{e}" }
# 	puts ">>"
# end


# tokens = line.split(" ")
# 	if specifier.include? tokens[0] 
# 		return true
# 	end
# 	if type.include? tokens[0] 
# 		return true
# 	end

#macro recognition
file = ""
File.open("files/wrong.c","r") do |f| 
			file = f.read
			f.close
end
puts file
file = file.gsub(";", "\n").split("\n").map(&:strip).reject(&:empty?)
code = explode!(file)
macro = ""
flag = false
output = {}
@code.each do |block|
	flag = false
	block.each do |line|
		#puts "next: #{line}"
		#puts "last_char: #{line.strip[-1]}"
		if line.include?("#define") then
			if line.strip[-1] != "\\" then #single line macro
				temp = line.gsub("#define","").strip.split(" ",2)
				name = temp[0]
				definition = temp[1]
			else #multiline macro
				flag = true
				macro.concat(line.gsub("#define","") + " ")
			end
		elsif flag == true #reading macro
			if line.strip[-1] == "\\"
				macro.concat(line)
			else 
				flag = false #stop reading macro
				macro.concat(line)
				macro = macro.strip
				#puts "FINAL MACRO #{macro}"
				index_delimiter = macro.index("(")
				if macro.index(" ") < index_delimiter then
					index_delimiter = macro.index(" ")
				end
				name = macro.slice(0,index_delimiter)
				definition = macro
				
			end
		else
			#puts "else: #{line}"
			next
		end
		#puts "macro: #{macro}"
		if flag == false then
			temp = []
			temp.push(name)
			temp.push(definition.gsub("\\",""))
			output[temp] = 0
		end

		
		#output[name + definition] = 0
	end
end

print output