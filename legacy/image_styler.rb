require 'nokogiri'
require 'awesome_print'
require 'securerandom'
require 'json'
require 'namae'

images_extensions = ['jpeg', 'png']

# wrap a child with a div
def wrap_image(img, doc)
    # create a node <div>
    wrapper = Nokogiri::XML::Node.new('div', doc)
    wrapper[:class] = img[:class] == 'inline' ?  'img-wrapper img-wrapper-inline' : 'img-wrapper';

    # wrap img with the wrapper div
    img.wrap(wrapper.to_html)
end


for i in 0..11

    doc = File.open("./source/document#{i}.html") { |f| Nokogiri::HTML(f) }

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


end