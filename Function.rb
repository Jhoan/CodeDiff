#!/usr/bin/env ruby

hash = {}
a = ["getc","getc(p) ..."]
hash[a] = 0


hash.each do |key,value|
	key.each { |k| print k+" "}
	print "#{value} "
	#puts "#{key[0]} #{value}"
end
