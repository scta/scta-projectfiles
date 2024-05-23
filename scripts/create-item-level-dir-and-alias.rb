#!/usr/bin/env ruby

require "nokogiri"
require "open-uri"
require "fileutils"

projectfile = ARGV[0]
projectfile_base = "/Users/jcwitt/Projects/scta/scta-projectfiles/"
#destination_base = "/Users/jcwitt/Projects/scta/scta-texts/"
destination_base = "/Users/jcwitt/Desktop/"
destination = destination_base + projectfile

file = projectfile_base + projectfile + ".xml"
doc = Nokogiri::XML(open(file))
items = doc.xpath("//item")

items.each do |item|
  id = item.attributes["id"].value
  puts "id: #{id}"
  FileUtils.mkdir_p "#{destination}/#{id}/"
  #FileUtils.touch "#{destination}/#{id}/readme.md"
  if item.attributes["alias"]
    idalias = item.attributes["alias"].value
    puts "alias: #{idalias}"
    
    FileUtils.mkdir_p "#{destination}/symlinks/"
    if !File.exist? "#{destination}/symlinks/#{idalias}"
      FileUtils.ln_s "../#{id}", "#{destination}/symlinks/#{idalias}"
    end
  end
end
