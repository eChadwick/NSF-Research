require 'json'
require 'pry'
require 'set'
require 'net/http'

# This script useses an API which is documented at https://ipinfodb.com/api
API_KEY = '90a81801f22e545660026726a5a051e6c22303fa7faeedfbdf206e65dd7e3b38'

puts 'Please pass country name as a string as an argument.' unless ARGV[0]

# Load the datafile and parse the json to a ruby hash.
data_file = File.read('Edge_Report_test1.json')
requests = JSON.parse(data_file)

# Compile list of unique IPs from requested Source Country and count the number of occurences of each.
country_ips = {}
requests.each do |r|
  if r['Source Country'] == ARGV[0]
    if country_ips[r['Source address']]
      country_ips[r['Source address']] += 1
    else
      country_ips[r['Source address']] = 1
    end
  end
end
country_ips = country_ips.sort_by(&:last).reverse

# Print IP data
puts "Unique IPs from #{ARGV[0]}: #{country_ips.count}\n\n"
puts "Requests by IP:\n---------------"
country_ips.each do |ip, count|
  puts "#{ip}: #{count}"
end

puts "\nTracing IPs. This will approximately #{(country_ips.count / 1.6 / 60).round(2)} minutes."

# Hit the API to get city level location data for country_ips.
last_request_time = nil
ip_trace_by_city = {}
country_ips.each do |ip|
  ip_trace = Net::HTTP.get(URI("http://api.ipinfodb.com/v3/ip-city/?key=#{API_KEY}&ip=#{ip.first}&format=json"))
  last_request_time = Time.now
  ip_trace = JSON.parse(ip_trace)
  if ip_trace_by_city[ip_trace['cityName']]
    ip_trace_by_city[ip_trace['cityName']] += 1
  else
    ip_trace_by_city[ip_trace['cityName']] = 1
  end
  # Throttling request rate to comply with API limit of 2 requests per second.
  while(Time.now < (last_request_time + 0.6)) do
  end
end
ip_trace_by_city =  ip_trace_by_city.sort_by(&:last).reverse

# Print City data.
puts "\nUnique Cities among IP locations: #{ip_trace_by_city.count}\n\n"
puts "IPs by City:\n----------------"
ip_trace_by_city.each do |city, count|
  puts "#{city}: #{count}"
end

puts "\nWould you like do dump this data to a text file? Enter 'Y' for yes, any other character for no."
input = $stdin.getc.upcase
exit unless input == 'Y'

outfile_name = "#{ARGV[0]}_drill_down_report-#{Time.now}"
outfile = File.open(outfile_name, 'w')

# Print IP data to file.
outfile.puts "Unique IPs from #{ARGV[0]}: #{country_ips.count}\n\n"
outfile.puts "Requests by IP:\n---------------"
country_ips.each do |ip, count|
  outfile.puts "#{ip}: #{count}"
end

# Print City data to file.
outfile.puts "\nUnique Cities among IP locations: #{ip_trace_by_city.count}\n\n"
outfile.puts "IPs by City:\n----------------"
ip_trace_by_city.each do |city, count|
  outfile.puts "#{city}: #{count}"
end
puts puts "Data saved to #{outfile_name}"
