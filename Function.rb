#!/usr/bin/env ruby
a = [["#define somethin","multiline","end"],["int main()","etc..."]]
a.each_with_index do |block,i|
	if i == 0 then
		next
	end
	block.each do |line|
		puts line
	end
end

