#!/bin/bash

echo "Adjusting table notes"
ruby adjust_depositi_notes.rb

echo "Performing tagger";
ruby tagger.rb

echo "Performing fulltexter";
ruby fulltexter.rb

echo "Performing indexer";
ruby indexer.rb

echo "Performing tocer";
ruby tocer.rb

echo "Performing styler";
ruby styler.rb

echo "Performing referer";
ruby referer.rb

echo "Performing final touches"
sed -i -e 's@color:@color:#@gi' ./output/output-tagged-full-text-styled-refered.html
sed -i -e 's@ @ @gi' ./json/fulltext.json
sed -i -e 's@ @ @gi' ./json/toc.json
sed -i -e 's@ @ @gi' ./json/index.json

echo "Copy generated files"
cp ./output/output-tagged-full-text-styled-refered.html ../PirateriaMusicale/dev/dataset/output.html
cp ./json/*.json ../PirateriaMusicale/dev/dataset/