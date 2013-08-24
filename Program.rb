#Class: Program
class Program
	#We'll store the ocurrences in hashes: Name=>Count
	@code = Array.new()
	@headers = Hash.new() 
	@defines = Hash.new()
	@functions = Hash.new() 
	@vars = Hash.new() #Main variables only
	def initialize(new_code)
		raise ArgumentError, "Expected Array but got #{new_code.class.name}" unless new_code.kind_of? Array
	end
	def explode! #Converts the array containing the code into an array of arrays where every inner array is a function
		
	end
	def get_vars(function) #Get the variable declarations of a function
	end

end
	
x = Program.new(["#include"]);
puts x