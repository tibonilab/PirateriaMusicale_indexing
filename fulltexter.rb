require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'


doc = File.open("./output/output-tagged-full-text.html") { |f| Nokogiri::HTML(f) }

list = []

doc.search('p').each do |s|
  list << {ref: s.[]('id'), transcription: s.text.strip.gsub(/\n/, " ").gsub(/\t/, " ").gsub(/\s+/, ' ')}
end

File.write("./json/fulltext.json", JSON.pretty_generate(list))
