#!/bin/bash

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

