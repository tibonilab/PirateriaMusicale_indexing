require 'nokogiri'

text = '<html> <body> <div> <span class="blah">XSS Attack document</span> </div> </body> </html>'
html = Nokogiri::HTML(text)


html.search('span').each do |node|

    link = Nokogiri::XML::Node.new('a', html)
    link['href'] = 'http://blah.com'

    node.wrap(link.to_html)

    

    # add it before the text
    

end



# # get the node span
# node = html.at_xpath('//span[@class="blah"]')
# # change its text content
# node.content = node.content.gsub('XSS', '')

# # create a node <a>
# link = Nokogiri::XML::Node.new('a', html)
# link['href'] = 'http://blah.com'
# link.content = 'XSS'

# # add it before the text
# node.children.first.add_previous_sibling(link)

# print it
puts html.to_html