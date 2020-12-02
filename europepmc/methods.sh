#!/bin/bash
cd fmrirct
for filename in ./PMC*; do
	echo "transforming" $filename/fulltext.xml "=>" $filename/sect.xml
	xsltproc -o ./$filename/sect.xml --novalid ../methods.xsl $filename/fulltext.xml 
done
cd ..

