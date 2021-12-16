fname = 'Tests/test1'
File.foreach(fname) do |line| 
  if line.start_with?('Elves: ')
    line = line.gsub(/,/, '').split()
    line -= ['Elves:']
    p line
  elsif line.start_with?('Dwarves: ')
    puts line
  else
    puts line
  end
end
