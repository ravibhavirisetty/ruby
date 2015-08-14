require 'rubygems'
require 'nokogiri'
require 'open-uri'

URL = "http://skicentral.com/"

HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}
levelOneLinks = Array.new
levelTwoLinks = Array.new
doc = Nokogiri::HTML(open(URL + 'resorts.html'))

statelabels = doc.css('.statelabel')
statelabels.each do |label|
  levelOneLinks << label["href"]
end

statelinks = doc.css('.statelink')
statelinks.each do |stlink|
  stateList = stlink.css("a")
  stateList.each do |list|
    levelOneLinks << list["href"]
  end
end

levelOneLinks.each do |location|
  if location != "turkey.html"
    resort = Nokogiri::HTML(open(URL + location))
    subResortList = resort.css("a[class='subresortlink']")
    
    subResortList.each do |subResort|
      if subResort.text == "Resort Overview"
        levelTwoLinks << subResort["href"]
      end
    end
  end
end

notFound = 0
found = 0
otherErrors = 0
emptyCount = 0
levelTwoLinks.each do |resortlink|
  begin
    page = Nokogiri::HTML(open(URL + resortlink))
    table = page.css('.statstable tr td')
    if !table.empty?
      found += 1
      name = page.at('.resorttitle').text
      puts "#{name}:#{table[4].text}:#{table[5].text}:#{table[6].text}:#{table[7].text}:#{table[10].text}:#{table[11].text}"
    else
      emptyCount += 1
    end
  rescue OpenURI::HTTPError => e
    if e.message == '404 Not Found'
      notFound += 1
    else
      otherErrors += 1
      raise e
    end
  end
end
puts "empty sites:#{emptyCount} found:#{found} not found:#{notFound} other errors:#{otherErrors}"
