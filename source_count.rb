require 'json'
require 'pry'

# Load the datafile and parse the json to a ruby hash.
data_file = File.read('Edge_Report_test1.json')
requests = JSON.parse(data_file)

# Count requests from each country.
request_sources = {}
requests.each do |r|
  if request_sources[r['Source Country']]
    request_sources[r['Source Country']] += 1
  else
    request_sources[r['Source Country']] = 1
  end
end
request_sources = request_sources.sort_by(&:last).reverse

# Print country request data.
puts "Requests by country:\n---------------------"
request_sources.each do |x, y|
  puts "#{x}: #{y}"
end

puts "\nWould you like do dump this list to a text file? Enter 'Y' for yes, any other character for no."
input = $stdin.getc.upcase
exit unless input == 'Y'

outfile_name = "Source_Count-#{Time.now}.txt"
outfile = File.open(outfile_name, 'w')
outfile.puts "Requests by country:\n---------------------"
request_sources.each do |x, y|
  outfile.puts "#{x}: #{y}"
end
puts "List saved to Source_Count-#{outfile_name}"
