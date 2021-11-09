require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'


docs = []

images_extensions = ['jpeg', 'png']

# wrap a child with a div
def wrap_image(img, doc)
  # create a node <div>
  wrapper = Nokogiri::XML::Node.new('span', doc)
  wrapper[:class] = img[:class] == 'inline' ?  'img-wrapper img-wrapper-inline' : 'img-wrapper';

  # wrap img with the wrapper div
  img.wrap(wrapper.to_html)
end

# wrap a child with a div
def wrap_chapter(chapter, doc, index)
  # create a node <div>
  wrapper = Nokogiri::XML::Node.new('div', doc)
  wrapper[:class] = "chapter-#{index}";

  # wrap img with the wrapper div
  chapter.wrap(wrapper.to_html);
end




for i in 0..11
  doc = File.open("./source/document#{i}.html") { |f| Nokogiri::HTML(f) }

  ## tag everything
  doc.search('p').each do |s|
    uniq = SecureRandom.hex(3)
    s[:id] = uniq
  end

  ## manage images
  doc.search('img').each do |img|
    file_extension = img[:src].split('.').last

    if images_extensions.include? file_extension
      img[:src] = img[:src]
      
      replace = "#{i}"
      if i < 10
      replace = "0" + replace
      end

      img[:src] = img[:src].gsub("media/", "((REPLACE_WITH_MEDIA_ENDPOINT))/chapter-#{replace}-").gsub('.png', '.jpg').gsub('.jpeg', '.jpg')

      # remove styles
      img.delete('style');

      # wrap image with a wrapper div
      wrap_image(img, doc)
    else
      # remove not valid img nodes
      img.remove
    end
  end

  # celan up some mess
  doc.search('div').each do |div|
    if div[:class] == 'stdfooter autogenerated'
      div.remove
    end
  end


  ## adjust notes refs
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
          e[:id] = e[:id] + note_chapter_subfix
          link = e.at('.link_return');
          link[:href] = link[:href] + note_chapter_subfix
      end
  end



  # add blockquotes into chapter 4
  if i == 4
    breakpoints_start = [];
    breakpoints_end = [];

    doc.search('p').each_with_index do |e, index|

      if e[:style] == 'text-align:right;' && e.child[:style] == 'font-size:8pt'

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


    # ap breakpoints_start
    # ap breakpoints_end

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
  end


  # generate a tagged file for each chapter
  File.write("./output/output-tagged-#{i}.html", doc.to_html);

  docs << doc.at('body').inner_html
end

header = '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
   </head>
   <body>'

footer = '</body></html>'

body = [];

## wrap chapters with peculiar .chapter-X class div
docs.each_with_index do |chapter, index|
  body << '<div class="chapter-' + index.to_s + '">' + chapter + '</div>';
end

# generate a unique file for full-text targeting
File.write("./output/output-tagged-full-text.html", header + body.join('') + footer)