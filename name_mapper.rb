require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'

doc = File.open("./source/appendix2.html") { |f| Nokogiri::HTML(f) }

names = {}
doc.search('span').each do |s|
    if s[:style] == 'font-size:10pt;font-weight:bold'

        names[s.text.strip] = s.text.strip + " " + s.next_element.text.strip

    end
end

ap names


map = {}

names.each do |name, text|

    ap name

    splitted = name.split(',')

    ap splitted

    if (splitted[1])
        key = splitted[1] + " " + splitted[0]
    else
        key = name
    end

    map[key.strip] = text
end

map["[N. N.] Bellinzaghi"] = "[N. N.] Bellinzaghi"
map["[N. N.] Lepont"] = "[N. N.] Lepont"
map["[senza indicazione di autore]"] = "[senza indicazione di autore]"
map["Adolphe Adam"] = "Adam, Adolphe Charles (1803–1856)"
map["Adolphe Le Carpentier"] = "Le Carpentier, Adolphe (1809–1869)"
map["Charles Philippe Lafont"] = "Lafont, Charles-Philippe (1781–1839)"
map["S. H. Kliegl"] = "Kliegl S. H. (sec. XIX)"


ap map

File.write("utils/name_map2.json", JSON.pretty_generate(map))
