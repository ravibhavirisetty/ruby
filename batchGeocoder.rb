# Raviteja Bhavirisetty

require 'rubygems'
require 'optparse'
require 'geocoder'
#require 'roo'
require 'spreadsheet'

# ravi DONE: rahul- this script for now supports only .xls files. 
# I'm facing trouble saving the data into the input file. So I save it as a new file for now.

# create a new hash that handles the input command
options = {}

commandLine = OptionParser.new do|opts|

  # Set a banner, displayed at the top of the help screen.
  opts.banner = "Usage: batchGeocoder.rb -i INPUT -s 'SHEET' -c 'COLUMNIN' -m 'ROWS' -n 'ROWE' -d 'COMLUMNOUT' -o 'OUTPUT' " + \
  				"[h]"
  
  # Define the options, and what they do
  options[:input] = nil
  opts.on( '-i', '--input FILE', 'Specify the input file' ) do|file|
    options[:input] = file
  end

  options[:sheet] = ""
  opts.on( '-s', '--sheet SHEET', String, 'Input spreadsheet name (.xls file only)' ) do|sheet|
    options[:sheet] = sheet
  end


  options[:columnin] = ""
  opts.on( '-c', '--columnin COLUMNIN', String, 'Input column number with addresses' ) do|columnin|
    options[:columnin] = columnin.to_i()
  end
  
  options[:rows] = ""
  opts.on( '-m', '--rows ROWS', String, 'Input start row number for geocode' ) do|rws|
    options[:rows] = rws.to_i()
  end

  options[:rowe] = ""
  opts.on( '-n', '--rowe ROWE', String, 'Input end row number for geocode' ) do|rwe|
    options[:rowe] = rwe.to_i()
  end

  options[:columnout] = ""
  opts.on( '-d', '--columnout COLUMNOUT', String, 'Output column number with geocodes' ) do|columnout|
    options[:columnout] = columnout.to_i()
  end

  options[:output] = nil
  opts.on( '-o', '--output FILE', 'Enter the output file name (without any extension)' ) do |file|
    options[:output] = file
  end
  
  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

#parses the command line.
commandLine.parse!

if (options[:input].nil? || options[:sheet].nil? || options[:columnin].nil? || options[:rows].nil? || options[:rowe].nil? || options[:columnout].nil? || options[:output].nil?)
  puts "Incorrect Options try running with -h"
  exit
end

# 'spreadsheet' gem documentation: http://spreadsheet.rubyforge.org/GUIDE_txt.html
# 'spreadsheet' example: https://gist.github.com/thebinarypenguin/4043752

inputPath = Dir.pwd + '/' + options[:input]

# checks the input file format

if File.extname(inputPath) != '.xls'
 puts 'Enter an input file with .xls format'
 exit
end

outPath = (Dir.pwd + '/' + options[:output] + '.xls')

if File.exists?(outPath)
  puts 'The output file name already exists.'
  print 'Please enter a different name: '
  outputName = gets.chomp()
  outPath = (Dir.pwd + '/' + outputName + '.xls')
end

book = Spreadsheet.open inputPath

puts 'spread sheet opened'
sheet = book.worksheet options[:sheet]

Geocoder.configure( :lookup => :yandex, :timeout => 5)

for i in options[:rows]..options[:rowe]

# inserting 1 sec delay in querying the geocodes to avoid API Over Query Limit
  #if i%10 == 0
  #  sleep 1.0
  #end
  sheet[i,options[:columnout]] = Geocoder.coordinates(sheet[i,options[:columnin]]).to_s()
  puts 'row ' + i.to_s() + ' coded.'
end

book.write outPath

puts 'geocoding completed.'







