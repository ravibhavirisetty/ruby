# Raviteja Bhavirisetty

require 'rubygems'
require 'nokogiri'
require 'open-uri'

mainURL = "http://www.yourmapper.com/list/137/"

HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

levelOneLinks = Array.new
levelTwoLinks = Array.new

pageCount = 1
puts 'scraping list of URLs'

# this loop extracts the URLs for list of the data points
for k in 1..426
  levelOneLinks << mainURL + k.to_s()
  pageCount += 1
end

pageCount -= 1
puts '#'+pageCount.to_s()+' pages extracted for links'

# saving the levelOneLinks into a text file
File.open("levelOneLinks.txt","w+") do |d|
  d.puts(levelOneLinks)
end
puts '#'+pageCount.to_s()+' links saved into "levelOneLinks.txt"'

pageCount = 1
puts 'scraping URLs with data points'

# this loop extracts the URLs of each data point
for i in 0..425
  page = Nokogiri::HTML(open(levelOneLinks[i]))
  link = page.css("#resultlist #sortabletable tr td a")
  if i<425
    for j in 0..49
      levelTwoLinks << link[j]["href"]
    end
  else
    for j in 0..42
      levelTwoLinks << link[j]["href"]
    end
  end
puts 'page #' + i.to_s()
pageCount += 1
end
pageCount -= 1
puts '#'+pageCount.to_s()+' URLs of pages with data points extracted.'

# saving the level two links into a text file
File.open("levelTwoLinks.txt","w+") do |d|
  d.puts(levelTwoLinks)
end
puts 'saved the level two links into "levelTwoLinks.txt"'

data = Array.new
dataPoint = 1
puts 'scraping data from pages'

file = File.open("dataExtract.txt","w+")

# this loop extracts all the data points
levelTwoLinks.each do |p|
  begin
	  dataPage = Nokogiri::HTML(open(p))
	  address = dataPage.css('table tr td div strong span')
	  location = dataPage.css('table tr td div div span[typeof="v:Geo"] span')
	  
	  # address:latitude:longitude:date
	  data << ":#{address.text}:#{location[0]["content"]}:#{location[1]["content"]}:#{date.text}"
	  puts ":#{address.text}:#{location[0]["content"]}:#{location[1]["content"]}:#{date.text}"
	  file << ":#{address.text}:#{location[0]["content"]}:#{location[1]["content"]}:#{date.text} \n"
  end
  dataPoint += 1
end

dataPoint -= 1
puts 'total data points extracted = '+dataPoint.to_s()

puts 'all the scrapped data saved into a text file "dataExtract.txt"'