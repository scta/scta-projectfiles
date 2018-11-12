#!/usr/bin/env ruby

require "nokogiri"
require "open-uri"
require "pry"
require "fileutils"

projectfile = ARGV[0]
#destination_base = "/Users/jcwitt/Desktop/test/"
destination_base = ARGV[1]
doc = Nokogiri::XML(open(projectfile))
items = doc.xpath("//item")

items.each do |item|
  id = item.attributes["id"].value
  puts "id: #{id}"
  if item.attributes["alias"]
    idalias = item.attributes["alias"].value
    puts "alias: #{idalias}"
    FileUtils.mkdir_p "#{destination_base}/#{id}/"
    FileUtils.touch "#{destination_base}/#{id}/readme.md"
    FileUtils.mkdir_p "#{destination_base}/symlinks/"
    if !File.exist? "#{destination_base}/symlinks/#{idalias}"
      FileUtils.ln_s "../#{id}", "#{destination_base}/symlinks/#{idalias}"
    end
  end
end
