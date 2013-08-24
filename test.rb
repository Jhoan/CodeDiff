#This file is for testing purposes only
code = Array.new(["#include<stdio.h>",
				"float foo(int,char)",
				"int main(){",
					"int x=0","float y=3",
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
code.each { |line| puts line }
puts "***************"
brace_count = 0
output = Array.new()
output.push(Array.new)
i = 0
code.each do |current_line| 
	#puts current_line
	if current_line.include? "{" 
		brace_count+=1
		if brace_count == 1
			output.push(Array.new)
			i+=1
		end
	end	
	
	if current_line.include? "}"
		brace_count -= 1
	end
	
	output[i].push(current_line)
end

output.each do |arr|  
	puts "*****"
	arr.each { |line| puts line }
	puts "*****"
end