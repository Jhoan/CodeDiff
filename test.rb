# require 'ostruct'
# table = []
# #1..10.times do |i|
# 	# temp = OpenStruct.new
# 	# temp.name = "int " * i
# 	# table.push(temp)
# #end
# print table
# i = 0
# table.each do |record|
# 	record.countA = i
# end
# table.each do |record|
# 	puts "#{record.name} #{record.countA}"
# end

# puts "++++#{table[0] == table[1]}"
a = [1,2,3,4,5,6,7]
a.map! do |e|
	if e > 3 then
		0
	else
		e
	end
end
print a