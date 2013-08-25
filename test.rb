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
				"float foo(int n,char d){",
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

line = "float foo(int,char)"
puts get_name(line)


# code.each do |line|
# 	puts line
# 	puts get_name(line)
# 	if is_var?(line) == false then
# 		temp = line.gsub(get_name(line),"")
# 		puts temp
# 	end
# end








# tokens = line.split(" ")
# 	if specifier.include? tokens[0] 
# 		return true
# 	end
# 	if type.include? tokens[0] 
# 		return true
# 	end