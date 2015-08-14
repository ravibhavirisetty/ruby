# Raviteja Bhavirisetty
# Date 05/02/2014

require 'rubygems'
require 'vine'
require 'json/pure'
require 'spreadsheet'

# URL being parsed: http://www.ocearch.org/#curriculum

########################## LOADING THE JSON FILE INTO THE CODE ###########################

# gem 'json/pure' - http://flori.github.io/json/doc/index.html
# this gem allows to import .json database files as Hashes

json = File.read('allSharkTracker.json')
input = JSON.parse(json)

puts 'input data loaded...'

# url for gem 'vine' - https://github.com/guangnan/vine
# this is an awesome ruby gem that i found which can help us easily parse through Hashes

################## CREATING WORKBOOK AND SPREADSHEETS TO WRITE THE DATA ##################

# creating workbook and individual sheets for each shark ping data
book = Spreadsheet::Workbook.new

sheets = Array.new
sheets[0] = book.create_worksheet
sheets[0].name = 'SharkList'

puts 'Sheet 1: Sharks List created.'

for i in (1..(input.length))
	sheets[i] = book.create_worksheet
	sheets[i].name = input[i-1].access('name')
	puts 'Sheet ' + (i+1).to_s() + ': ' + input[i-1].access('name') + ' created.'
end

############################## FORMATTING THE SPREADSHEETS ###############################

# formatting the first rows of all the sheets

# formatting a cell: http://goo.gl/iyhtYY
format = Spreadsheet::Format.new :weight => :bold

headings = ['tagIdNumber','name','species','stageOfLife','length','weight','tagDate','tagLocation']

for i in 0..(headings.length-1)
  sheets[0].row(0).set_format(i, format)
  sheets[0][0,i] = headings[i]
end

sheetHeadings = ['active','id','datetime','tz_datetime','latitude','longitude']

for i in (1..(sheets.length-1))
	for j in (0..(sheetHeadings.length-1))
		sheets[i].row(0).set_format(j, format)
		sheets[i][0,j] = 'ping' + sheetHeadings[j]
	end
end

############################ WRITING ALL SHARK MASTER LIST ###############################

# saving the master list of all sharks being tracked
puts 'writing shark master list...'

# WORK TO DO: edit the loop to include PING COUNT from each shark in a column

for i in (1..(input.length-1))
	for j in (0..(headings.length-1))
		sheets[0][i,j] = input[i].access(headings[j])
	end
end

puts 'writing shark master list completed...'

########################## WRITING THE PING DATA OF EACH SHARK ###########################

# parsing the JSON file for pings of each shark
puts 'parsing data for shark pings...'

totalPingCount = 0

for s in 0..(input.length-1)
	puts input[s].access('name') + ' has ' + input[s].access('pings').length.to_s() + ' pings.'
	totalPingCount += input[s].access('pings').length
	for i in 0..(input[s].access('pings').length-1)
		for j in (0..(sheetHeadings.length-1))
			x = 'pings.' + i.to_s() + '.' + sheetHeadings[j]
			sheets[s+1][i+1,j] = input[s].access(x)
		end		
	end
end

puts 'total number of pings obtained from all the sharks = ' + totalPingCount.to_s()
puts 'writing all the data into excel workbook...'

book.write 'sharkTrackerMegaList.xls'

puts 'shark tracker data save successful.'
puts 'file saved as \'sharkTrackerMegaList.xls\''

##################################### END_OF_PROGRAM #####################################
