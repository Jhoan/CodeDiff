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

vars = Hash.new()
# code.each { |line| puts line }
# puts "***************"
brace_count = 0
output = Array.new()
output.push(Array.new)
index = 0
code.each do |current_line| 
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


line = "float     **foo      (int a,int b)"
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
puts line.slice(i,len).strip



# output.each do |p|
# 	p.each do |line|
# 		is_var? line
# 	end
# end






# tokens = line.split(" ")
# 	if specifier.include? tokens[0] 
# 		return true
# 	end
# 	if type.include? tokens[0] 
# 		return true
# 	end