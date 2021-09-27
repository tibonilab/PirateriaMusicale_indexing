require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'

doc = File.open("./output/output-tagget-full-text-styled.html") { |f| Nokogiri::HTML(f) }

headers = [];

missing = [];

found = []

doc.search('p').each do |node|

    if node[:class] && node[:class].include?('heading6')

        string = node.child.text.strip

        if string =~ /\d/
            exists = headers.any? { |header| header[:id] == node[:id] }

            if !exists
                headers << { id: node[:id], string: string }
            end
        end 
    end

    if node.children.count == 1
        child = node.child

        if child[:style] == 'font-size:10pt;font-weight:bold' && child.text.strip.include?('Figura')
            string = child.text.strip

            # ap child
            # ap node

            exists = headers.any? { |header| header[:id] == node[:id] }

            if !exists
                # ap string 
                headers << { id: node[:id], string: string }
            end 
        end

    end

end


pics = File.open("./output/output-tagged-10.html") { |f| Nokogiri::HTML(f) }

pics.search('p').each do |node|

    if node.children.count == 1
        child = node.child

        if child[:style] == 'font-size:10pt;font-weight:bold' && child.text.strip.include?('Illustrazione')
            string = child.text.strip

            # ap child
            # ap node

            exists = headers.any? { |header| header[:id] == node[:id] }

            if !exists
                # ap string 
                headers << { id: node[:id], string: string }
            end 
        end

    end

end 

headers = headers.sort_by { |link| link[:string].to_i == 0 ? 999999999999 + link[:string][0].ord : link[:string].to_i }

# ap headers

# headers.each do |h|
#  ap h[:string]
# end



doc.search('p').each do |node|

    if node.children.count > 1

        node.children.each do |child|

            if !node[:class] && child[:style] == 'font-size:11pt;font-weight:bold' && child.text.strip.length > 3 && child.text.strip =~ /\d/
                search = child.text.strip
                
                # puts 'searching for '
                # ap search

                match = headers.any? { |node| node[:string].include?(search) }

                if match
                    referer = headers.select { |header| header[:string].start_with? search }

                    if referer.count > 0
                        # create a node <a>
                        link = Nokogiri::XML::Node.new('a', doc)
                        link[:href] = "#" + referer[0][:id]
                        link[:class] = 'anchor-link'
                        link[:target] = '_blank'

                        # add it before the text
                        child.wrap(link.to_html)

                        # ap child.parent

                        found << { id: node[:id], string: search }
                    else
                        missing << { id: node[:id], string: search, url: "http://pirateriamusicale.rism.digital/book##{node[:id]}" }
                    end 
                else
                    missing << { id: node[:id], string: search, url: "http://pirateriamusicale.rism.digital/book##{node[:id]}" }
                end
            end

            if child[:style] == 'font-size:10pt;font-weight:bold' && child.text.strip.length > 3 && child.text.strip =~ /\d/
                search = child.text.strip
                
                # puts 'searching for '
                # ap search

                match = headers.any? { |node| node[:string].include?(search) }

                if match
                    referer = headers.select { |header| header[:string].start_with? search }

                    if referer.count == 1
                        # create a node <a>
                        link = Nokogiri::XML::Node.new('a', doc)
                        link[:href] = "#" + referer[0][:id]
                        link[:class] = 'anchor-link'
                        link[:target] = '_blank'

                        # add it before the text
                        child.wrap(link.to_html)

                        # ap child.parent

                        found << { id: node[:id], string: search }

                        # ap node
                    elsif referer.count > 1
                        # ap referer
                    else
                        missing << { id: node[:id], string: search, url: "http://pirateriamusicale.rism.digital/book##{node[:id]}" }
                    end 
                else
                    missing << { id: node[:id], string: search, url: "http://pirateriamusicale.rism.digital/book##{node[:id]}" }
                end
            end
        end
    end
end

# ap missing

File.write("./utils/headers.json", JSON.pretty_generate(headers))
File.write("./utils/missing.json", JSON.pretty_generate(missing))
File.write("./utils/found.json", JSON.pretty_generate(found))

File.write("./output/output-tagged-full-text-styled-refered.html", doc)

puts "found"
ap found.count
puts "missing"
ap missing.count;