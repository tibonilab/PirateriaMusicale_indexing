require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'


doc = File.open("./output/output-tagged-full-text.html") { |f| Nokogiri::HTML(f) }

h1 = [];

doc.search('p').each do |node|
    
    if node.child[:style] == 'font-size:14pt;font-weight:bold'

        if !h1.any? { |s| node.child.text.strip.include?(s) }
            h1 << node.child.text.strip

            node[:class] = 'heading1'
        else 
            node[:class] = 'heading2'
        
        end
        ap node
    end


    if node.child[:style] == 'font-size:14pt;font-weight:bold;color:E7E6E6'
        node[:class] = 'heading2'

        ap node
    end

    if node.child[:style] == 'font-weight:bold;color:44546A' && node[:style] == 'text-align:center;'
        node[:class] = 'heading3'

        ap node
    end

    if node.child[:style] == 'font-weight:bold;color:44546A' && h1.any? { |s| s.include? (node.parent.child.text.strip) }
        node[:class] = 'heading3'

        ap node
    end

    if node.child[:style] == 'font-size:11pt;font-style:italic'
        node.child[:class] = 'heading4'

        ap node.child
    end


    if node.child[:style] == 'font-size:11pt;text-decoration:underline'
        node[:class] = 'heading5'

        ap node.child
    end


    if node.child[:style] == 'font-size:11pt;font-weight:bold'
        node[:class] = 'heading6'

        ap node.child
    end


    if node.child[:style] == 'font-size:10pt;font-weight:bold;color:44546A'
        node[:class] = 'heading6'

        ap node.child
    end

    if node.child[:style] == 'text-decoration:underline;color:44546A'
        node[:class] = 'heading5'

        ap node.child
    end
end

File.write('./output/output-tagged-full-text-styled.html', doc);