#!/bin/bash
# dependencies: wget xmllint
set -eux

town="stralsund"

wiki_export="https://de.wikipedia.org/wiki/Spezial:Exportieren/"
wiki_page_basename="Stralsunder_Straßennamen/"

currentdir=$(pwd)
workdir="cache/stralsund"

mkdir -p $workdir
cd $workdir

for i in {A..Z}
do
  link=$wiki_export$wiki_page_basename$i
  echo $link
  wget -O $i.xml $link
  # select the <text> content from the the xml | get lines starting with * | remove the * and whitespaces, remove opening link brackets until the pipe, remove opening link brackets, remove closing link markdown, remove parenthesis
  content=$(xmllint --xpath "//*[local-name()='text']/text()" $i.xml || true)
  if [ -n "$content" ]
  then
    echo "$content" | grep ^\* | sed 's/\*\s*//g ; s/\[\[.*|//g ; s/\[\[//g ; s/\]\].*$//g ; s/([^)]*)//g' | grep -v "^''" > $i.txt
  fi
done

find -name '*.txt' -print0 | xargs -r0 sed -e 's/[[:blank:]]\+$// ; s/^[[:blank:]]\+//' -i

cat *.txt > $currentdir/$town.txt

cd $currentdir

