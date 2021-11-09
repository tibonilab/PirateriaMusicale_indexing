require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'


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
  
  if s[:style] == "font-size:10pt;font-weight:bold" && s.text.include?('Illustrazione')
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
                target: "04f014"
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
      }
    ]
  }
}

File.write("./json/toc.json", JSON.pretty_generate(dataset))
