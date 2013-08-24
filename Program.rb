#Class: Program
class Program
	#We'll store the ocurrences in hashes: Name=>Count
	@headers = Hash.new()
	@defines = Hash.new()
	@functions = Hash.new()
	@vars = Hash.new() #Main variables only
	def initialize(code)
		raise ArgumentError, "Expected Array but got #{code.class.name}" unless code.kind_of? Array
	end

end
	
x = Program.new(["#include"]);
puts x