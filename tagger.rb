require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'


docs = []

for i in 0..11
  doc = File.open("document#{i}.html") { |f| Nokogiri::HTML(f) }

  doc.search('p').each do |s|
    uniq = SecureRandom.hex(3)
    s[:id] = uniq
  end

  # generate a tagged file for each chapter
  File.write("output-tagged-#{i}.html", doc.to_html);

  docs << doc.at('body').inner_html
end

# generate a unique file for full-text targeting
File.write("output-tagged.html", docs.join('\n\n\n'))