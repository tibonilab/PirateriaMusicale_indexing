require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'


for i in 0..11
    doc = File.open("./source/document#{i}.html") { |f| Nokogiri::HTML(f) }

    note_chapter_subfix = '-chapter-' + i.to_s;

    ## update the link to the note
    doc.search('span').each do |e|
        if e[:id] && e[:id].start_with?('ftn')
            
            e[:id] = e[:id] + note_chapter_subfix
            if e.child[:href]
                e.child[:href] = e.child[:href] + note_chapter_subfix
            end
        end
    end

    ## update the actual note id and return href
    doc.search('div').each do |e|
        if e[:id] && e[:id].start_with?('ftn')
            #ap e
            e[:id] = e[:id] + note_chapter_subfix

            link = e.at('.link_return');
            link[:href] = link[:href] + note_chapter_subfix
            ap link
        end
    end

end