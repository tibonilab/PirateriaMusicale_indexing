require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'


doc = File.open("./source/document4.html") { |f| Nokogiri::HTML(f) }


breakpoints_start = [];
breakpoints_end = [];

doc.search('p').each_with_index do |e, index|

    if e[:style] == 'text-align:right;' && e.child[:style] == 'font-size:8pt'

        ap e

        counter = 1;

        next_el = e.next_element
        while next_el && next_el[:style] == 'text-align:right;' 
            next_el = next_el.next_element
            counter = counter + 1
        end

        if !breakpoints_start.include?(index + counter)
            breakpoints_start << index + counter
        end

    end


    if e.child[:style] == 'font-size:10pt;text-decoration:underline';
        breakpoints_end << index
    end
end


ap breakpoints_start
ap breakpoints_end

collector = [];

should_add = false

divs = []
div_index = 0;
doc.search('p').each_with_index do |e, index|

    if breakpoints_start.include?(index)
        should_add = true
        divs[div_index] = Nokogiri::XML::Node.new('div', doc)
        divs[div_index][:class] = 'blockquote'
        e.after(divs[div_index])
    end

    if breakpoints_end.include?(index)
        collector.each do |collected|
            divs[div_index].add_child(collected)

            # ap divs[div_index]
        end
        
        should_add = false
        collector = []
        div_index = div_index + 1
    end

    if should_add
        collector << e
        e.remove
    end

end


#ap doc