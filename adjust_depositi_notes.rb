require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'


class String
    def is_numeric?
        self.to_i.to_s == self
    end
end

doc = File.open("./source/document5-col-ref.html") { |f| Nokogiri::HTML(f) }


doc.search('p').each_with_index do |e, index|

    if e.children[0] && e.children[0][:class] && e.children[0][:class].start_with?('table-col')

        k = 0
        noteToMove = false;
        while e.children[k]
            if e.children[k][:id] && e.children[k].child.child.text.to_i < 460
                # ap e.children[k].child.child.text
                noteToMove = e.children[k]
                e.children[k].remove
            end
            k = k + 1;
        end

        if noteToMove
            e.add_child(noteToMove)
            # ap e
        end
        
    end

end



File.write("./source/document5-col-ref-NOTES.html", doc.to_html);
