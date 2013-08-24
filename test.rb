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
					"}",
							
				"return 0",
				"}",
				"float foo(int n,char d){",
					"code",
				"}"])

vars = Hash.new()
code.each { |line| puts line }
puts "***************"
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
	specifier = Array.new(["signed", "unsigned","short","long","char","int","float","double"])
	#type = Array.new(["char","int","float","double"])
	specifier.any? { |s| return true if line[s] }
	return false
	# type.each do |t|
	# 	if line.include? t
	# 		puts "Type #{line}"
	# 	end
	# end
end

output.each do |func|
	func.each do |line|

		puts line + "is var? " + is_var?(line).to_s

	end
end




