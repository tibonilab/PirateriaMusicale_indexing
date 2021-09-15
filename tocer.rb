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
        chapter5[:group] << {name: s.text.strip, link: []}
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


ap chapter5


# init and compose toc dataset
toc = [
    {
        name: "1. Introduzione",
        subtitle: "Ambientazione tematica",
        link: [
            {
                label: "Introduzione", 
                target: "103c54"
            }
        ]
    },
    chapter2,
    chapter3,
    chapter4,
    chapter5
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
