files = []
File.open("files/temp/file2commented.c","r") do |file| 
			files.push(file.read) 
			file.close
end

print files[0].gsub(/(\/\*([^*]|[\r\n]|(\*+([^*\/]|[\r\n])))*\*+\/)|(\/\/.*)/,"")
