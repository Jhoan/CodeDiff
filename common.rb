#common methods

def is_var?(line) #return true if a line of code is a variable declaration
	raise ArgumentError, "Expected String but got #{line.class.name} instead" unless line.is_a? String
	specifier = Array.new(["void", "signed", "unsigned","short"])
	type = Array.new(["long","char","int","float","double"])

	tokens = line.split(" ")
	if specifier.include? tokens[0] 
		return true
	end
	if type.include? tokens[0] 
		return true
	end




	return false
end

#int foo(char);
#int foo(void)
#int 
#int a;