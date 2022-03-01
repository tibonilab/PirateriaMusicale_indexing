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

class String
  def is_numeric?
      self.to_i.to_s == self
  end
end


should_create_inline_row = false;
from_index = 0
stop_index = 0


for i in 0..11

  if i == 5 
    doc = File.open("./source/document#{i}-col-ref.html") { |f| Nokogiri::HTML(f) }
  else
    doc = File.open("./source/document#{i}.html") { |f| Nokogiri::HTML(f) }
  end

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

        
        if e[:class] == 'TABLE-HERE'
          collector << Nokogiri::HTML('<table class="small-table">
            <tr>
                  <td>Serie</td>
                  <td>At</td>
                  <td>N.<sup>°</sup></td>
                  <td>47645</td>
                  <td>Una Banconota di</td>
                  <td>f.</td>
                  <td>100.–</td>
            </tr>
            <tr>
                  <td>"</td>
                  <td>Me</td>
                  <td>"</td>
                  <td>91017</td>
                  <td style="text-align: center">idem</td>
                  <td>"</td>
                  <td>100.–</td>
            </tr>
            <tr>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td style="text-align: right">assieme</td>
                  <td>f.</td>
                  <td>200.–</td>
            </tr>
          </table>').to_html;
          e.remove
        end

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

  if i == 5

    doc.search('p').each_with_index do |e, index|

      next if e[:class] == 'no-inline-tab'

          # search for heading
        if e.child[:style] == 'font-size:10pt;font-weight:bold;text-decoration:underline;color:44546A'
            e[:class] = 'heading7'
        end

        # search for rowIds to be tranformed to inline-tab
        if (e.children[0].text.strip.is_numeric? || e.children[0].text.gsub('[', '').gsub(']', '').strip.is_numeric?) && e.children[0][:style] == 'font-size:10pt;color:44546A'
          number = e.children[0]
          note = false

          # check if the number has a note appended
          if e.children[1] && e.children[1][:id]
              note = e.children[1]

              e.children[1].remove
          end

          e.children[0].remove

          # generate scaffolding
          div = Nokogiri::XML::Node.new('span', doc)
          div[:class] = 'numeric-value'

          e.children[0].add_previous_sibling(div)
          div.add_child(number);

          if note
              div.add_child(note)
          end 

          nodes = e.children.to_a
          container = Nokogiri::XML::Node.new('span', doc)
          container[:class] = 'text-value'

          k = 1
          while nodes[k]
            container.add_child(nodes[k])
            k = k + 1
          end

          e.children[0].after(container)
          e[:class] = 'inline-tab'
          
          # ap e

        # test otherwise if there is a single <span /> to be splitted into 2 chunks 
        # <span>NNNN</span><span>TEXT TEXT TEXT</span>
        # OR <span>[NNNN]</span><span>TEXT TEXT TEXT</span>
        elsif (/\d/.match(e.children[0].text[0]) || e.children[0].text[0] == '[' && /\d/.match(e.children[0].text[1])) && e.children[0][:style] == 'font-size:10pt;color:44546A'          
          splitted = e.children[0].text.split
          style = e.children[0][:style];

          # generate scaffolding
          div = Nokogiri::XML::Node.new('span', doc)
          div[:class] = 'numeric-value'

          e.children[0].add_previous_sibling(div)
          e.children[1].remove
          
          # put number into first span
          first_span = Nokogiri::XML::Node.new('span', doc)
          first_span.inner_html = splitted[0]
          first_span[:style] = style

          # test if there is a note for the number
          note = false

          if e.children[1] && e.children[1][:id]
            note = e.children[1]
            e.children[1].remove
          end

          if note
            first_span.add_child(note)
          end

          # remove number from splitted string
          splitted.delete_at(0);

          # put text purged of number into second span
          second_span = Nokogiri::XML::Node.new('span', doc);
          second_span.inner_html = splitted.join(' ');
          second_span[:style] = style

          div.add_child(first_span)
          e.children[0].after(second_span)

          # cycle all remaining spans containing text
          nodes = e.children.to_a

          container = Nokogiri::XML::Node.new('span', doc)
          container.add_child(second_span);
          container[:class] = 'text-value'

          k = 1
          while nodes[k]
            container.add_child(nodes[k])
            k = k + 1
          end

          e.children[0].after(container)

          e[:class] = 'inline-tab'

        elsif e.children[0][:style] == 'font-size:10pt;font-weight:bold;color:C00000' || (e.children[1] && e.children[1][:style] == 'font-size:10pt;font-weight:bold;color:C00000')
          e[:class] = e[:class].to_s + ' heading8'
        end

        if e.children[0][:style] == 'font-size:11pt;font-weight:bold;text-decoration:underline'
          e[:class] = 'inline-table'
          
          k = 1;
          while e.children[k]
            if e.children[k].text.include?('rid.')

                e.children[k].inner_html = 'rid. per pf.'

                pf = Nokogiri::XML::Node.new('span', doc);
                # solo = Nokogiri::XML::Node.new('span', doc);
                altro = Nokogiri::XML::Node.new('span', doc);
    
                pf.inner_html = 'pf. solo'
                # solo.inner_html = 'solo'
                altro.inner_html = 'altro'
    
                pf[:style] = e.children[k][:style]
                # solo[:style] = e.children[k][:style]
                altro[:style] = e.children[k][:style]
    
                e.add_child(pf)
                # e.add_child(solo)
                e.add_child(altro)

                break
            end

            if e.children[k].text.include?('profano')

                splitted = e.children[k].text.strip.split

                e.children[k].inner_html = splitted[0];

                splitted.delete_at(0);

                splitted.each do |chunk|
                    span = Nokogiri::XML::Node.new('span', doc);
                    span[:style] = e.children[k][:style];

                    span.inner_html = chunk

                    e.add_child(span)
                end

            end

              k = k + 1;
          end

          should_create_inline_rowId = true
          from_index = index

          if e.children[0].text.strip.start_with?('totale')
              stop_index = index + 1
          end
        end

        if should_create_inline_rowId && index > from_index

            if index == stop_index
                should_create_inline_rowId = false
            end

            # ap e

            e[:class] = 'inline-table-rowId';

        end

    end


    currentTableId = 0;
    rowId = 0;

    shouldIncrementTableId = false;
    souldAddNextElementAsRow = false;

    doc.search('p').each_with_index do |e, index|

        if shouldIncrementTableId 
            shouldIncrementTableId = false;
            currentTableId = currentTableId + 1;
            rowId = 0;
        end

        if souldAddNextElementAsRow && e.children[0][:style] != 'font-size:11pt;font-weight:bold;text-decoration:underline'

            e[:tableId] = currentTableId;
            e[:rowId] = rowId;
            e[:class] = 'table-row'

            rowId = rowId + 1;
        end

        if e.children[0][:style] == 'font-size:11pt;font-weight:bold;text-decoration:underline'
            
            e[:tableId] = currentTableId;
            e[:rowId] = rowId;
            e[:class] = 'table-row'

            souldAddNextElementAsRow = true;

            rowId = rowId + 1;

        end

        if e.children[0][:style] == 'font-size:10pt;font-weight:bold;color:0000FF'
          shouldIncrementTableId = true
          souldAddNextElementAsRow = false;
        end

    end


    tables = [];

    max_cols = 7;

    doc.search('p').each_with_index do |e, index|

        if e[:class] == 'table-row'

            if e[:rowId].to_i == 0

                max_cols = e.search('span').to_a.count;

                tables[e[:tableId].to_i] = Nokogiri::XML::Node.new('table', doc);
                tables[e[:tableId].to_i][:class] = 'table-quantitativi'

                e.add_previous_sibling(tables[e[:tableId].to_i]);

            end
            
            tr = Nokogiri::XML::Node.new('tr', doc);
            if e.children[0][:style] == 'font-size:11pt;font-weight:bold;text-decoration:underline'
                tr[:class] = 'table-row-head'
            end

            col = 0
            while col < max_cols
                td = Nokogiri::XML::Node.new('td', doc);
                td.inner_html = "&nbsp;";
                
                e.search('span').each_with_index do |segment, segmentId|
                  if segment[:id].nil?

                    if !segment[:ref_col]
                        if segmentId == col
                            td.inner_html = segment.text

                            if segment.next_element && segment.next_element[:id]
                                td.inner_html = td.inner_html + segment.next_element.to_html
                            end
                        end
                    else
                        if segment[:ref_col].to_i == col + 1
                            td.inner_html = segment.text

                            if segment.next_element && segment.next_element[:id]
                                td.inner_html = td.inner_html + segment.next_element.to_html
                            end
                        end
                    end

                  end
                end
                
                tr.add_child(td)

                col = col + 1
            end

            tables[e[:tableId].to_i].add_child(tr)

            e.remove
        end

    end


  end


  if i == 6 

    doc.search('p').each_with_index do |e, index|
    
      if e.children[0] && (e.children[0][:style] == 'font-size:10pt;color:44546A' || e.children[0][:style] == 'font-size:10pt;font-style:italic;font-weight:bold;color:44546A')
  
        e[:class] = 'inline-columns'

        # clean up the elements if ar note nodes
        e.children.each_with_index do |element, index|
          if !element.is_a?(Nokogiri::XML::Element)
            element.remove
          end
        end

        # test if we already have the numeric value wrapped into its <span> element ...
        if e.children[0].text.gsub('°', '').strip.is_numeric?

          # if it is so we just add the .numeric-value class to the <span>
          e.children[0][:class] = 'numeric-value'

          # check for related notes to keep into the .numeric-value wrapper
          if e.children[1] && e.children[1][:id]
              notelink = e.children[1];
              e.children[1].remove
              e.children[0].add_child(notelink)
          end
          
        # otherwise the numeric value is not single wrapped into its <span>
        # we are going to manage that on the following lines
        else
          # check how many span are there...
          if e.children.count == 1
            # split the text in order to check if there are numeric chunks in the first places
            splitted = e.children[0].text.strip.gsub(' ', ' ').split;

            # test for "NNN [MMM]" type of caption into second chunk
            if splitted[1] && splitted[1][0] == '[' && splitted[1][splitted[1].length - 1] == ']'

              span = Nokogiri::XML::Node.new('span', doc);
              span[:style] = e.children[0][:style]
              span[:class] = 'numeric-value';
              span.inner_html = splitted[0] + ' ' + splitted[1];

              splitted.delete_at(0);
              splitted.delete_at(0);

              text = Nokogiri::XML::Node.new('span', doc);
              text[:style] = e.children[0][:style]
              text.inner_html = splitted.join(' ')

              e.add_child(span)
              e.add_child(text)

              e.children[0].remove
            
            # else if the first chunk is numeric we want to wrap it into a .numeric-value <span>
            elsif splitted[0].is_numeric? || splitted[0][0] == '°'
              span = Nokogiri::XML::Node.new('span', doc);
              span[:style] = e.children[0][:style]
              span[:class] = 'numeric-value';
              span.inner_html = splitted[0];

              splitted.delete_at(0);

              text = Nokogiri::XML::Node.new('span', doc);
              text[:style] = e.children[0][:style]
              text.inner_html = splitted.join(' ')

              e.add_child(span)
              e.add_child(text)

              e.children[0].remove
            end

          # manage here a collection of <span>
          else

            # search for "NNN [MMM]" type of caption
            if e.children[0].text.strip.gsub(' ', '').gsub(' ', '').gsub('[', '').gsub(']', '').is_numeric?

              # if it is so we just add the .numeric-value class to the <span>
              e.children[0][:class] = 'numeric-value'

              # check for related notes to keep into the .numeric-value wrapper
              if e.children[1] && e.children[1][:id]
                  notelink = e.children[1];
                  e.children[1].remove
                  e.children[0].add_child(notelink)
              end

            else

              # split the text in order to check the content
              splitted = e.children[0].text.strip.gsub(' ', ' ').split;

              # test for "NNN [MMM]" type of caption into second chunk
              if splitted[1] && splitted[1][0] == '[' && splitted[1][splitted[1].length - 1] == ']'

                span = Nokogiri::XML::Node.new('span', doc);
                span[:style] = e.children[0][:style]
                span[:class] = 'numeric-value';
                span.inner_html = splitted[0] + ' ' + splitted[1];

                splitted.delete_at(0);
                splitted.delete_at(0);

                text = Nokogiri::XML::Node.new('span', doc);
                text[:style] = e.children[0][:style]
                text.inner_html = splitted.join(' ')

                e.children[0].remove

                e.children[0].add_previous_sibling(text)
                e.children[0].add_previous_sibling(span)
              
              # else if the first chunk is numeric we want to wrap it into a .numeric-value <span>
              elsif splitted[0].is_numeric? || splitted[0][0] == '°' || splitted[0].gsub('-','').is_numeric? || splitted[0].gsub('/','').is_numeric?
                span = Nokogiri::XML::Node.new('span', doc);
                span[:style] = e.children[0][:style]
                span[:class] = 'numeric-value';
                span.inner_html = splitted[0];

                splitted.delete_at(0);

                text = Nokogiri::XML::Node.new('span', doc);
                text[:style] = e.children[0][:style]
                text.inner_html = splitted.join(' ')
                
                e.children[0].remove

                e.children[0].add_previous_sibling(text)
                e.children[0].add_previous_sibling(span)

              end
            end
          end
        end
      end
    end
  end

  if [7,8,9].include?(i)

    doc.search('p').each_with_index do |e, index|

      if e.children[0] && e.children[0][:style] == 'font-size:11pt;font-weight:bold'

        elements = [];

        next_el = e.next_element;

        while next_el && next_el[:style] == 'text-align:right;'

          elements << next_el

          next_el = next_el.next_element
        end

        if elements.count > 0
          
          wrapper = Nokogiri::XML::Node.new('div', doc)
          wrapper[:class] = 'small-right-caption'

          elements.each do |paragraph|
            wrapper.add_child(paragraph.to_html)

            # ap paragraph

            paragraph.remove
          end

          # ap wrapper
          e.add_next_sibling(wrapper)

        end


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