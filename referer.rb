require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'

doc = File.open("./output/output-tagged-full-text-styled.html") { |f| Nokogiri::HTML(f) }

headers = [];

missing = [];

found = []

# wrap a child with a link
def wrap(child, referer, doc)
    # create a node <a>
    link = Nokogiri::XML::Node.new('a', doc)
    link[:href] = "#" + referer[0][:id]
    link[:class] = 'anchor-link'
    link[:target] = '_blank'

    # add it before the text
    child.wrap(link.to_html)
end

# add node to missing array
# this is used to generate a JSON for manual adjustments
def add_missing(missing, node, search)
    missing << { id: node[:id], string: search, url: "http://pirateriamusicale.rism.digital/book##{node[:id]}" }
end


def try_matching_extracted(extracted, headers, child, doc, found, node, search)
    referer = headers.select { |header| header[:string].start_with? extracted }

    if referer.count > 0

        wrap(child, referer, doc)

        found << { id: node[:id], string: search, target: referer[0][:id] }

        return true;
    else
        if extracted[-1] == '.' || extracted[-1] == ' ' || extracted[-1] == ' '
            puts 'TRAILING FOUND'
            ap extracted
            extracted = extracted[0...-1]
            return try_matching_extracted(extracted, headers, child, doc, found, node, search)
        end
    end

    return false;
end


# the matching logic
def try_matching(node, child, headers, found, missing, doc) 

    search = child.text.strip.gsub(/\s+/, ' ')

    if search[-1] == '.' || search[-1] == ' ' || search[-1] == ' '
        search = search[0...-1]
    end 

    referer = headers.select { |header| header[:string].start_with? search }

    if referer.count > 0

        wrap(child, referer, doc)

        found << { id: node[:id], string: search, target: referer[0][:id]  }
    else
        # here are managed all the peculiar matching logic
        matched = false;

        # search for "STRING.YEAR.N[-M]" pattern
        if !matched &&  /\w+.\d+.\d+/.match?(search)
            extracted = search.match(/\w+.\d+.\d+/)[0].to_s;
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        # search for "STRING.STRING.YEAR.N[-M]" pattern
        elsif !matched &&  /\w+.\w+.\d+.\d+/.match?(search)
            extracted = search.match(/\w+.\w+.\d+.\d+/)[0].to_s;
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        # peculiar strings to care about
        elsif !matched &&  search == "Carteggio"
            extracted = "4. Carteggio"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "Cronologia"
            extracted = "3. Cronologia"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "Catalogo Bustelli-Rossi"
            extracted = "6. Cataloghi - Catalogo delle musiche prodotte da Achille Bustelli-Rossi"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "Studio generale"
            extracted = "2. Studio generale"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "Catalogo Pozzi"
            extracted = "6. Cataloghi - Catalogo delle musiche prodotte da Carlo Pozzi"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)
        
        elsif !matched &&  search == "Catalogo Euterpe Ticinese"
            extracted = "6. Cataloghi - Catalogo delle musiche prodotte da Euterpe Ticinese"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "Illustrazioni"
            extracted = "10. Illustrazioni"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  (search == "Depositi" || search == "5. Depositi " || search == "5. Depositi ")
            extracted = "5. Depositi"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "Cataloghi"
            extracted = "6. Cataloghi"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "Petizioni"
            extracted = "7. Petizioni"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "Avvisi musicali"
            extracted = "8. Avvisi musicali"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "Documenti vari"
            extracted = "9. Documenti vari"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "2. Studio generale"
            extracted = "2. Studio generale"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "2. Studio generale"
            extracted = "2. Studio generale"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == '5. Depositi - Spinelli'
            extracted = "5. Depositi - Gioachino Spinelli / Euterpe Ticinese (1838–1854)"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == '5. Depositi - Pozzi'
            extracted = "5. Depositi - Carlo Pozzi (1836–1855)"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == '5. Depositi - Veladini'
            extracted = "5. Depositi - Francesco Veladini (1860–1866)"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "Euterpe Ticinese - Catalogo"
            extracted = "6. Cataloghi - Catalogo delle musiche prodotte da Euterpe Ticinese"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "6. Cataloghi - Catalogo Euterpe Ticinese"
            extracted = "6. Cataloghi - Catalogo delle musiche prodotte da Euterpe Ticinese"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "6. Cataloghi -Catalogo Euterpe Ticinese"
            extracted = "6. Cataloghi - Catalogo delle musiche prodotte da Euterpe Ticinese"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "6. Cataloghi - Catalogo Euterpe Ticinese"
            extracted = "6. Cataloghi - Catalogo delle musiche prodotte da Euterpe Ticinese"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "7. Petizioni - Spinelli (Euterpe Ticinese)"
            extracted = "7. Petizioni - Spinelli / Euterpe Ticinese (1840–1854)"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "8. Avvisi musicali"
            extracted = "8. Avvisi musicali"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "8. Avvisi musicali - Pozzi"
            extracted = "8. Avvisi musicali pubblicati da Carlo Pozzi"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "8. Avvisi musicali - Spinelli"
            extracted = "8. Avvisi musicali pubblicati da Gioachino Spinelli (Euterpe Ticinese)"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "8. Avvisi musicali - Bustelli-Rossi"
            extracted = "8. Avvisi musicali pubblicati da Achille Bustelli-Rossi"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        elsif !matched &&  search == "9. Documenti vari"
            extracted = "9. Documenti vari"
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        # serach for trailing chars
        elsif !matched && search[-1] == '.' || search[-1] == ' ' || search[-1] == ' '
            extracted = search[0...-1]
            matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)

        end
        
        # search for "1843.2" references before or after
        if /^\d+\.\d+/.match?(search)

            regexp = /\w[-a-zA-Z]+\.?\w[a-z\.]+/
            # check previous siblings
            if child.previous_sibling && child.previous_sibling.previous_sibling && regexp.match?(child.previous_sibling.previous_sibling.text)
                extracted = child.previous_sibling.previous_sibling.text.match(regexp)[0].to_s + search

                matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)
            else
                if child.parent[:class] && child.parent[:class] == 'anchor-link'
                    matched = true;
                else

                    # search references looping previous siblings
                    previous = child.previous_sibling
                    while previous && !regexp.match?(previous.text)
                        previous = previous.previous_sibling
                    end

                    extracted = previous.text.match(regexp)[0].to_s + child.text 
                    matched = try_matching_extracted(extracted, headers, child, doc, found, node, search)
                end

            end
        end
    
        if !matched 
            # && !search.include?('Pozzi.petizioni') 
            && !(node[:class] && node[:class].include?('heading'))
            # puts 'NOT FOUND'
            ap search
            # ap node[:id]
            add_missing(missing, node, search)
        end 
    end
end




# generating Headers
doc.search('p').each do |node|

    if node[:class] && node[:class].include?('heading2')

        string = node.child.text.strip.gsub(/\s+/, ' ')

        if string =~ /\d/
            exists = headers.any? { |header| header[:id] == node[:id] }

            if !exists
                headers << { id: node[:id], string: string }
            end
        end 
    end

    if node[:class] && node[:class].include?('heading1')

        string = node.child.text.strip.gsub(/\s+/, ' ')

        if string =~ /\d/
            exists = headers.any? { |header| header[:id] == node[:id] }

            if !exists
                headers << { id: node[:id], string: string }
            end
        end 
    end

    if node[:class] && node[:class].include?('heading6')

        string = node.child.text.strip.gsub(/\s+/, ' ')

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
            string = child.text.strip.gsub(/\s+/, ' ')

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


# Generating "Illustrazioni" Headers
pics = File.open("./output/output-tagged-10.html") { |f| Nokogiri::HTML(f) }

pics.search('p').each do |node|

    if node.children.count == 1
        child = node.child

        if child[:style] == 'font-size:10pt;font-weight:bold' && child.text.strip.include?('Illustrazione')
            string = child.text.strip.gsub(/\s+/, ' ')

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

        child_count = 0;

        node.children.each do |child|

            # try matching inside content body
            if !node[:class] && child[:style] == 'font-size:11pt;font-weight:bold' && child.text.strip.length > 3 && child.text.strip =~ /\d/
                try_matching(node, child, headers, found, missing, doc)
            end

            if !node[:class] && child[:style] == 'font-size:11pt;font-weight:bold' && child.text.strip.length > 3
                try_matching(node, child, headers, found, missing, doc)
            end

            # Carteggio
            if child[:style] == 'font-size:10pt;font-weight:bold' && child.text.strip.length > 3 && child.text.strip =~ /\d/
                try_matching(node, child, headers, found, missing, doc)
            end

            # Heading Depositi
            if child_count > 0 && node[:class] && node[:class] == 'heading6' && child[:style] == 'font-size:11pt;font-weight:bold' && child.text.strip.length > 3 && child.text.strip =~ /\d/
                try_matching(node, child, headers, found, missing, doc)
            end

            # try matching inside notes
            if node.parent[:class] && node.parent[:class] == 'noteBody' && child[:style] == 'font-size:10pt;font-weight:bold' && child.text.strip.length > 3
                try_matching(node, child, headers, found, missing, doc)
            end

        child_count = child_count + 1
        end
    else 
        if node.parent[:class] && node.parent[:class] == 'noteBody'
            # try matching inside notes --single childs
            if node.child[:style] == 'font-size:10pt;font-weight:bold' && node.child.text.strip.length > 3
                try_matching(node, node.child, headers, found, missing, doc)
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