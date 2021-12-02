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

      e[:class] = 'inline-tab'

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
      
      first_span = Nokogiri::XML::Node.new('span', doc)
      first_span.inner_html = splitted[0]
      first_span[:style] = style

      splitted.delete_at(0);

      second_span = Nokogiri::XML::Node.new('span', doc);
      second_span.inner_html = splitted.join(' ');
      second_span[:style] = style

      div.add_child(first_span)
      e.children[0].after(second_span)

      e[:class] = 'inline-tab'

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


# ap tables



File.write("./test-output-5.html", doc.to_html);