require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'

=begin
names_repo = File.readlines("names.txt")
hand_map = {
"Alvars, E. Parish": "Parish Alvars, E.  (Elias Parish Alvars, 1808–1849)",
"Ricci, Louis": "Ricci, Luigi (1805–1859)",
"de Bériot, Charles Auguste": "Bériot, Charles Auguste de (1802–1870)",
"fils, Manuel Garcia": "Garcia fils, Manuel (1805–1906)",
"Hunten, François": "Hünten, François (Franz Hünten, 1792–1878)",
"Paccini, Giovanni": "Pacini, Giovanni (1796–1867)",
"Lanner, Joseph": "Lanner, Josef (1801–1843)",
"Le Carpentier, Adolphe": "Lecarpentier, Adolphe (Adolphe Clair Le Carpentier, 1809–1869)",
"Wolff, Edward": "Wolff, Edouard (Edward Wolff, 1816–1880)",
"Ernst, Wilhelm": "Ernst, Heinrich Wilhelm (1814–1865)",
"Alvars, Parish": "Parish Alvars, E.  (Elias Parish Alvars, 1808–1849)",
"von Flotow, Friedrich": "Flotow, Friedrich von (1812–1883)",
"de Meyer, Léopold": "Meyer, Léopold de (Leopold von Meyer, 1816–1883)",
"De Meyer, Leopold": "Meyer, Léopold de (Leopold von Meyer, 1816–1883)",
"De Meyer, Leopold": "Meyer, Léopold de (Leopold von Meyer, 1816–1883)"
}
=end

name_map = data_hash = JSON.parse(File.read("../utils/name_map2.json"))

doc = File.open("../output/output-tagged-6.html") { |f| Nokogiri::HTML(f) }

index = {}

doc.search('span').each do |s|
  if s[:style] == "font-size:10pt;font-weight:bold;color:44546A"

    uniq = s.parent[:id]

    first_number = s.parent.next_element.child
    if first_number[:style] != 'font-size:10pt;color:44546A'
      first_number = first_number.parent.next_element.child
    end 

    splitted = first_number.text.split(/\t/)    
    test_title = splitted[0].gsub('°', '').to_i

    if test_title == 0
      first_number = first_number.parent.next_element.child
      splitted = first_number.text.split(/\t/)
    end


    title = splitted[0].strip

    if title == ''
      title = splitted[1]
    end
    
    string_to_test = s.text.strip

    if ['Adolphe Adam', 'Adolphe Charles Adam'].include?(string_to_test)
      string_to_test = 'Adolphe Adam'
      ap string_to_test
    end

    if ['Adolphe Lecarpentier', 'Adolphe Le Carpentier'].include?(string_to_test)
      string_to_test = 'Adolphe Lecarpentier'
      ap string_to_test
    end

    if ['Wilhelm Ernst', 'Heinrich Wilhelm Ernst'].include?(string_to_test)
      string_to_test = 'Wilhelm Ernst'
      ap string_to_test
    end    

    if ['Luigi Ricci', 'Louis Ricci'].include?(string_to_test)
      string_to_test = 'Luigi Ricci'
      ap string_to_test
    end    
    
    if ['Errico Petrella', 'Enrico Petrella'].include?(string_to_test)
      string_to_test = 'Errico Petrella'
      ap string_to_test
    end    
    
    if ['E. Parish Alvars', 'Parish Alvars'].include?(string_to_test)
      string_to_test = 'E. Parish Alvars'
      ap string_to_test
    end    
        
    if ['Giovanni Pacini', 'Giovanni Paccini'].include?(string_to_test)
      string_to_test = 'Giovanni Pacini'
      ap string_to_test
    end    
            
    if ['Joseph', 'Méry'].include?(string_to_test)
      string_to_test = 'Joseph'
      ap string_to_test
    end    
                
    if ['Léopold de Meyer', 'Leopold De Meyer', 'Leopold De Meyer'].include?(string_to_test)
      string_to_test = 'Léopold de Meyer'
      ap string_to_test
    end    
    
                
    if ['Josef Lanner', 'Joseph Lanner'].include?(string_to_test)
      string_to_test = 'Josef Lanner'
      ap string_to_test
    end    
    
                
    if ['Franz Hünten', 'François Hunten', 'François Hünten'].include?(string_to_test)
      string_to_test = 'Franz Hünten'
      ap string_to_test
    end          
             
    if ['Edward Wolff', 'Edouard Wolff'].include?(string_to_test)
      string_to_test = 'Edward Wolff'
      ap string_to_test
    end    
    
    if ['Charles Philippe Lafont', 'Charles-Philippe Lafont'].include?(string_to_test)
      string_to_test = 'Charles-Philippe Lafont'
      ap string_to_test
    end   

    if ['George Alexander Osborne', 'George Alexander de Osborne'].include?(string_to_test)
      string_to_test = 'George Alexander Osborne'
      ap string_to_test
    end    
    
    
    if ['Heinrich Wilhelm Ernst', 'Wilhelm Ernst'].include?(string_to_test)
      string_to_test = 'Heinrich Wilhelm Ernst'
      ap string_to_test
    end    
    
    
    
    if !index.include?(string_to_test)
      index[string_to_test] = []
    end
    
    index[string_to_test] << [uniq, title]
    
  end
end


ap index

sorted = index.sort

sorted_hash = {}

sorted.each do |i|
  sorted_hash[i[0]] = index[i[0]]
end 

ap sorted_hash




composers = []

normalized_names = {}

sorted_hash.each do |name, pages|

  normalized_name = name_map[name]
  
  composer = {}
  composer[:name] = normalized_name
  links = []
  pages.each do |p|
    links << {label: p[1].strip, target: p[0], chapter: "06"}
  end


  composer[:link] = links.sort_by { |link| link[:label].to_i == 0 ? 999999999999 + link[:label][0].ord : link[:label].to_i }

  composers << composer
end

composers = composers.sort_by { |c| c[:name].downcase }

ap composers


# dataset = {
#   index: {
#     group: [
#       {
#         name: "Composers6",
#         group: composers
#       }
#     ]
#   }
# }

# ap dataset

# File.write("index.json", JSON.pretty_generate(dataset))

=begin
  n = Namae.parse(name)[0].sort_order
  
  found = false
  names_repo.each do |nr|
    if nr.strip.downcase.include?(n.strip.downcase)
      #puts "YOOO #{n}"
      found = true
      
      normalized_names[name] = nr.strip
    end
  end
  
  if !found
    hand_map.each do |k, v|
      normalized_names[name] = v.strip if k.to_s.strip.downcase == n.strip.downcase
    end
  end
  
  puts n if !found
=end