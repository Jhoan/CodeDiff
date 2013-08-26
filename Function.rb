#!/usr/bin/env ruby

a = ["   fdsjlfdlkj    "," ,smfsjdkl"]
a.each do |line|
	line = line.strip()
	if line.start_with? "fds"
		puts "holoa"
	end
		
end
