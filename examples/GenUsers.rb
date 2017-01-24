require 'random_word_generator'

out_file = File.new("users.csv", "w+")

out_file.puts("name,surname,email,mobile,groups,password")

for i in 1..99
	temp = RandomWordGenerator.word
	out_file.write(temp + ",")													# name
	out_file.write(temp + ",")													# surname
	out_file.write(temp + RandomWordGenerator.word + "@filler.co.za,")			# email
	out_file.write(",")															# mobile
	out_file.write("reportviewer,")												# groups
	out_file.write(temp + "\n")													# password
end

temp = RandomWordGenerator.word
out_file.write(temp + ",")													# name
out_file.write(temp + ",")													# surname
out_file.write(temp + RandomWordGenerator.word + "@filler.co.za,")			# email
out_file.write(",")															# mobile
out_file.write("reportviewer,")												# groups
out_file.write(temp)

out_file.close()