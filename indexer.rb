require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'





name_map = data_hash = JSON.parse(File.read("utils/name_map.json"))

doc = File.open("output/output-tagged-5.html") { |f| Nokogiri::HTML(f) }

index = {}

doc.search('span').each do |s|
  if s[:style] == "font-size:10pt;font-weight:bold;color:C00000"
    uniq = s.parent[:id]
    
    
    prev = s.parent.previous_element
    found = false
    title = ""
    for a in 1..250 do
      prev.search('span').each do |t|
        if t[:style] == "font-size:11pt;font-weight:bold"
          #puts t
          found = true
          title = t.text
          break
        end
      end
      break if found
      prev = prev.previous_element
    end
    
    if !found
      puts s.text
      ap prev
    end

    # normalizing names
    string_to_test = s.text.strip

    if ['Adolphe Adam', 'Adolphe Charles Adam'].include?(string_to_test)
      string_to_test = 'Adolphe Adam'
    end

    if ['Adolphe Lecarpentier', 'Adolphe Le Carpentier'].include?(string_to_test)
      string_to_test = 'Adolphe Lecarpentier'
    end

    if ['Wilhelm Ernst', 'Heinrich Wilhelm Ernst'].include?(string_to_test)
      string_to_test = 'Wilhelm Ernst'
    end    

    if ['Luigi Ricci', 'Louis Ricci'].include?(string_to_test)
      string_to_test = 'Luigi Ricci'
    end    
    
    if ['Errico Petrella', 'Enrico Petrella'].include?(string_to_test)
      string_to_test = 'Errico Petrella'
    end    
    
    if ['E. Parish Alvars', 'Parish Alvars'].include?(string_to_test)
      string_to_test = 'E. Parish Alvars'
    end    
        
    if ['Giovanni Pacini', 'Giovanni Paccini'].include?(string_to_test)
      string_to_test = 'Giovanni Pacini'
    end    
            
    if ['Joseph', 'Méry'].include?(string_to_test)
      string_to_test = 'Joseph'
    end    
                
    if ['Léopold de Meyer', 'Leopold De Meyer', 'Leopold De Meyer'].include?(string_to_test)
      string_to_test = 'Léopold de Meyer'
    end    
    
                
    if ['Josef Lanner', 'Joseph Lanner'].include?(string_to_test)
      string_to_test = 'Josef Lanner'
    end    
    
                
    if ['Franz Hünten', 'François Hunten', 'François Hünten'].include?(string_to_test)
      string_to_test = 'Franz Hünten'
    end          
             
    if ['Edward Wolff', 'Edouard Wolff'].include?(string_to_test)
      string_to_test = 'Edward Wolff'
    end    
    
    if !index.include?(string_to_test)
      index[string_to_test] = []
    end
    
    index[string_to_test] << [uniq, title]
    
  end
end




composers = []

normalized_names = {}

index.each do |name, pages|

  normalized_name = name_map[name]
  
  composer = {}
  composer[:name] = normalized_name
  
  links = []
  pages.each do |p|
    links << {label: p[1].strip, target: p[0], chapter: "05"}
  end

  composer[:link] = links.sort_by { |link| link[:label].to_i == 0 ? 999999999999 + link[:label][0].ord : link[:label].to_i }

  composers << composer
end

composers = composers.sort_by { |c| c[:name] }








name_map2 = data_hash = JSON.parse(File.read("./utils/name_map2.json"))

doc = File.open("./output/output-tagged-6.html") { |f| Nokogiri::HTML(f) }

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
    
    # normalizing names
    string_to_test = s.text.strip

    if ['Adolphe Adam', 'Adolphe Charles Adam'].include?(string_to_test)
      string_to_test = 'Adolphe Adam'
    end

    if ['Adolphe Lecarpentier', 'Adolphe Le Carpentier'].include?(string_to_test)
      string_to_test = 'Adolphe Lecarpentier'
    end

    if ['Wilhelm Ernst', 'Heinrich Wilhelm Ernst'].include?(string_to_test)
      string_to_test = 'Wilhelm Ernst'
    end    

    if ['Luigi Ricci', 'Louis Ricci'].include?(string_to_test)
      string_to_test = 'Luigi Ricci'
    end    
    
    if ['Errico Petrella', 'Enrico Petrella'].include?(string_to_test)
      string_to_test = 'Errico Petrella'
    end    
    
    if ['E. Parish Alvars', 'Parish Alvars'].include?(string_to_test)
      string_to_test = 'E. Parish Alvars'
    end    
        
    if ['Giovanni Pacini', 'Giovanni Paccini'].include?(string_to_test)
      string_to_test = 'Giovanni Pacini'
    end    
            
    if ['Joseph', 'Méry'].include?(string_to_test)
      string_to_test = 'Joseph'
    end    
                
    if ['Léopold de Meyer', 'Leopold De Meyer', 'Leopold De Meyer'].include?(string_to_test)
      string_to_test = 'Léopold de Meyer'
    end    
    
                
    if ['Josef Lanner', 'Joseph Lanner'].include?(string_to_test)
      string_to_test = 'Josef Lanner'
    end    
    
                
    if ['Franz Hünten', 'François Hunten', 'François Hünten'].include?(string_to_test)
      string_to_test = 'Franz Hünten'
    end          
             
    if ['Edward Wolff', 'Edouard Wolff'].include?(string_to_test)
      string_to_test = 'Edward Wolff'
    end    
    
    if ['Charles Philippe Lafont', 'Charles-Philippe Lafont'].include?(string_to_test)
      string_to_test = 'Charles-Philippe Lafont'
    end   

    if ['George Alexander Osborne', 'George Alexander de Osborne'].include?(string_to_test)
      string_to_test = 'George Alexander Osborne'
    end    
    
    if ['Heinrich Wilhelm Ernst', 'Wilhelm Ernst'].include?(string_to_test)
      string_to_test = 'Heinrich Wilhelm Ernst'
    end    
    
    if !index.include?(string_to_test)
      index[string_to_test] = []
    end
    
    index[string_to_test] << [uniq, title]
    
  end
end



composers2 = []

index.each do |name, pages|

  normalized_name = name_map2[name]
  
  composer = {}
  composer[:name] = normalized_name
  
  links = []
  pages.each do |p|
    links << {label: p[1].strip, target: p[0], chapter: "06"}
  end

  composer[:link] = links.sort_by { |link| link[:label].to_i == 0 ? 999999999999 + link[:label][0].ord : link[:label].to_i }

  composers2 << composer
end

composers2 = composers2.sort_by { |c| c[:name] }









chapter2 = {
    link: []
}

doc = File.open("./output/output-tagged-2.html") { |f| Nokogiri::HTML(f) }

doc.search('span').each do |s|
  # matching main section title
  if s[:style] == "font-size:14pt;font-weight:bold"

    subtitle = s.parent.next_element.children.text
    
    chapterName = s.text.strip
    chapter2 = {
        name: chapterName,
        subtitle: s.parent.next_element.children.text,
        link: []
    }
    
  end

  # matching paragraphs
  if s[:style] == "font-size:11pt;font-style:italic"
    prev = s.parent
    if prev.children.count == 1
      chapter2[:link] << {label: s.text, target: prev.[]('id'), chapter: "02" }
    end
  end

end

chapter3 = {
    link: []
}

doc = File.open("./output/output-tagged-3.html") { |f| Nokogiri::HTML(f) }

doc.search('span').each do |s|
  # matching main section title
  if s[:style] == "font-size:14pt;font-weight:bold"

    subtitle = s.parent.next_element.children.text
    
    chapterName = s.text.strip
    chapter3 = {
        name: chapterName,
        subtitle: s.parent.next_element.children.text,
        link: []
    }
    
  end

  # matching paragraphs
  if s[:style] == "font-size:11pt;font-weight:bold"
    prev = s.parent
    if prev.children.count == 1
        chapter3[:link] << {label: s.text, target: prev.[]('id'), chapter: "03" }
    end
  end

end


chapter4 = {
    link: []
}

doc = File.open("./output/output-tagged-4.html") { |f| Nokogiri::HTML(f) }

doc.search('span').each do |s|
  # matching main section title
  if s[:style] == "font-size:14pt;font-weight:bold"

    subtitle = s.parent.next_element.children.text
    
    chapterName = s.text.strip
    chapter4 = {
        name: chapterName,
        subtitle: s.parent.next_element.children.text,
        link: []
    }
    
  end

  # matching paragraphs
  if s[:style] == "font-size:11pt;font-weight:bold"
    prev = s.parent
    if prev.children.count == 1
        chapter4[:link] << {label: s.text, target: prev.[]('id'), chapter: "04" }
    end
  end

end

chapter5 = {
    group: []
}

doc = File.open("./output/output-tagged-5.html") { |f| Nokogiri::HTML(f) }

titlefound = false;
paragraphkey = 0;
paragraphs = {}

doc.search('span').each do |s|
  # matching main section title
  if s[:style] == "font-size:14pt;font-weight:bold"
    if !titlefound
        titlefound = true
    
        subtitle = s.parent.next_element.children.text
        
        chapterName = s.text.strip
        chapter5 = {
            name: chapterName,
            subtitle: s.parent.next_element.children.text,
            group: []
        }
    else
        chapter5[:group] << {name: s.text.strip, target: s.parent.[]('id'), link: []}
        paragraphs[paragraphkey] = []
        paragraphkey += 1
    end
  end

  if s[:style] == "font-weight:bold;color:44546A"

    if paragraphs[paragraphkey - 1].nil? && paragraphkey > 0
        ap "init paragraph for key #{paragraphkey}"
        paragraphs[paragraphkey - 1] = []
    end

    if paragraphkey > 0
        paragraphs[paragraphkey - 1] << {label: s.text.strip, target: s.parent.[]('id'), chapter: "05"}
    end
  end

end

key = 0
chapter5[:group].each do |mp|
    chapter5[:group][key][:link] = paragraphs[key]
    key += 1
end




chapter6 = {
    group: []
}

doc = File.open("./output/output-tagged-6.html") { |f| Nokogiri::HTML(f) }

titlefound = false;
paragraphkey = 0;
paragraphs = {}

doc.search('span').each do |s|
  # matching main section title
  if s[:style] == "font-size:14pt;font-weight:bold"
    if !titlefound
        titlefound = true
    
        subtitle = s.parent.next_element.children.text
        
        chapterName = s.text.strip
        chapter6 = {
            name: chapterName,
            subtitle: s.parent.next_element.children.text,
            group: []
        }
    else
      chapter6[:group] << {name: s.text.strip, target: s.parent.[]('id'), link: []}
        paragraphs[paragraphkey] = []
        paragraphkey += 1
    end
  end

  if s[:style] == "font-weight:bold;color:44546A"

    if paragraphs[paragraphkey - 1].nil? && paragraphkey > 0
        ap "init paragraph for key #{paragraphkey}"
        paragraphs[paragraphkey - 1] = []
    end

    if paragraphkey > 0
        paragraphs[paragraphkey - 1] << {label: s.text.strip, target: s.parent.[]('id'), chapter: "06"}
    end
  end

end

key = 0
chapter6[:group].each do |mp|
  chapter6[:group][key][:link] = paragraphs[key]
    key += 1
end




chapter7 = {
    group: []
}

doc = File.open("./output/output-tagged-7.html") { |f| Nokogiri::HTML(f) }

titlefound = false;
paragraphkey = 0;
paragraphs = {}

doc.search('span').each do |s|
  # matching main section title
  if s[:style] == "font-size:14pt;font-weight:bold"
    if !titlefound
        titlefound = true
    
        subtitle = s.parent.next_element.children.text
        
        chapterName = s.text.strip
        chapter7 = {
            name: chapterName,
            subtitle: s.parent.next_element.children.text,
            link: []
        }
    else
      chapter7[:link] << {label: s.text.strip, target: s.parent.[]('id'), chapter: "07"}
      # chapter7[:group] << {name: s.text.strip, link: []}
      # paragraphs[paragraphkey] = []
      # paragraphkey += 1
    end
  end

  # if s[:style] == "font-size:11pt;font-weight:bold"

  #   if paragraphs[paragraphkey - 1].nil? && paragraphkey > 0
  #       ap "init paragraph for key #{paragraphkey}"
  #       paragraphs[paragraphkey - 1] = []
  #   end

  #   if paragraphkey > 0
  #       paragraphs[paragraphkey - 1] << {label: s.text.strip, target: s.parent.[]('id'), chapter: "05"}
  #   end
  # end

end

# key = 0
# chapter7[:group].each do |mp|
#   chapter7[:group][key][:link] = paragraphs[key]
#     key += 1
# end







chapter8 = {
    group: []
}

doc = File.open("./output/output-tagged-8.html") { |f| Nokogiri::HTML(f) }

titlefound = false;
paragraphkey = 0;
paragraphs = {}

doc.search('span').each do |s|
  # matching main section title
  if s[:style] == "font-size:14pt;font-weight:bold"
    if !titlefound
        titlefound = true
    
        subtitle = s.parent.next_element.children.text
        
        chapterName = s.text.strip
        chapter8 = {
            name: chapterName,
            subtitle: s.parent.next_element.children.text,
            link: []
        }
    else
      chapter8[:link] << {label: s.text.strip, target: s.parent.[]('id'), chapter: "08"}
      # chapter7[:group] << {name: s.text.strip, link: []}
      # paragraphs[paragraphkey] = []
      # paragraphkey += 1
    end
  end

  # if s[:style] == "font-size:11pt;font-weight:bold"

  #   if paragraphs[paragraphkey - 1].nil? && paragraphkey > 0
  #       ap "init paragraph for key #{paragraphkey}"
  #       paragraphs[paragraphkey - 1] = []
  #   end

  #   if paragraphkey > 0
  #       paragraphs[paragraphkey - 1] << {label: s.text.strip, target: s.parent.[]('id'), chapter: "05"}
  #   end
  # end

end

# key = 0
# chapter7[:group].each do |mp|
#   chapter7[:group][key][:link] = paragraphs[key]
#     key += 1
# end







chapter9 = {
    group: []
}

doc = File.open("./output/output-tagged-9.html") { |f| Nokogiri::HTML(f) }

titlefound = false;
paragraphkey = 0;
paragraphs = {}

doc.search('span').each do |s|
  # matching main section title
  if s[:style] == "font-size:14pt;font-weight:bold"
    if !titlefound
        titlefound = true
    
        subtitle = s.parent.next_element.children.text
        
        chapterName = s.text.strip
        chapter9 = {
            name: chapterName,
            subtitle: s.parent.next_element.children.text,
            link: []
        }
    end
  end
  
  if s[:style] == "font-size:11pt;font-weight:bold"
    chapter9[:link] << {label: s.text.strip, target: s.parent.[]('id'), chapter: "09"}
  end

end





chapter10 = {
    group: []
}

doc = File.open("./output/output-tagged-10.html") { |f| Nokogiri::HTML(f) }

titlefound = false;
paragraphkey = 0;
paragraphs = {}

doc.search('span').each do |s|
  # matching main section title
  if s[:style] == "font-size:14pt;font-weight:bold"
    if !titlefound
        titlefound = true
    
        subtitle = s.parent.next_element.children.text
        
        chapterName = s.text.strip
        chapter10 = {
            name: chapterName,
            # subtitle: s.parent.next_element.children.text,
            link: []
        }
    end
  end
  
  if s[:style] == "font-size:10pt;font-weight:bold"
    chapter10[:link] << {label: s.text.strip, target: s.parent.[]('id'), chapter: "10"}
  end

end





chapter11 = {
    group: []
}

doc = File.open("./output/output-tagged-11.html") { |f| Nokogiri::HTML(f) }

titlefound = false;
paragraphkey = 0;
paragraphs = {}

doc.search('span').each do |s|
  # matching main section title
  if s[:style] == "font-size:14pt;font-weight:bold"
    if !titlefound
        titlefound = true
    
        subtitle = s.parent.next_element.children.text
        
        chapterName = s.text.strip
        chapter11 = {
            name: chapterName,
            # subtitle: s.parent.next_element.children.text,
            link: []
        }
    end
  end
  
  if s[:style] == "font-size:11pt;text-decoration:underline"
    chapter11[:link] << {label: s.text.strip, target: s.parent.[]('id'), chapter: "11"}
  end

end


# init and compose toc dataset
toc = [
    {
        name: "1. Introduzione",
        subtitle: "Ambientazione tematica",
        link: [
            {
                label: "Introduzione", 
                target: "5900fe"
            }
        ]
    },
    chapter2,
    chapter3,
    chapter4,
    chapter5,
    chapter6,
    chapter7,
    chapter8,
    chapter9,
    chapter10,
    chapter11
]

dataset = {
  index: {
    group: [
      {
        name: "Toc",
        group: toc
      },
      {
        name:  "Composers5",
        group: composers
      },
      {
        name: "Composers6",
        group: composers2
      }
    ]
  }
}

File.write("./json/index.json", JSON.pretty_generate(dataset))
