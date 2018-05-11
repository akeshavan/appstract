#Getting and transforming EuropePMC content

## searching EuropePMC

### install getpapers 
http://github.com/getpapers has all the instructions

### search EuropePMC
Create a query (may be useful to test it manually on europepmc.org first.
```
"fmri RCT"
````
should search for FMRI and Randomised Controlled Trial.
Combine this to:
```
getpapers -o fmrirct -q "fmri RCT" -x 
```
`fmrirct` will be the output directory. `-x` asks for XML to be downloaded. Output is relative to the directory where you ran `getpapers`

### download
Note - the numbers depend on the configuration and date and will not be reproducible.
On 2018-05-11 we got:
```
info: Searching using eupmc API
info: Found 314 open access results
warn: This version of getpapers wasn't built with this version of the EuPMC api in mind
warn: getpapers EuPMCVersion: 5.3.2 vs. 6.0.0 reported by api
Retrieving results [==============================] 100% (eta 0.0s)
info: Done collecting results
info: Saving result metadata
info: Full EUPMC result metadata written to eupmc_results.json
info: Individual EUPMC result metadata records written
info: Extracting fulltext HTML URL list (may not be available for all articles)
info: Fulltext HTML URL list written to eupmc_fulltext_html_urls.txt
warn: Article with pmcid "PMC5803602" was not Open Access (therefore no XML)
warn: Article with pmcid "PMC5751534" was not Open Access (therefore no XML)
... [ignore warnings at this stage]
warn: Article with pmcid "PMC2934520" was not Open Access (therefore no XML)
info: Got XML URLs for 297 out of 314 results
info: Downloading fulltext XML files
Downloading files [==============----------------] 46% (138/297) [78.8s elapsed, eta 90.8]
... ending
info: Downloading fulltext XML files
Downloading files [==============================] 100% (297/297) [157.5s elapsed, eta 0.0]
info: All downloads succeeded!
```
### directory
The top directory `fmirct` is called a `CProject`. Contentmine.org has lots of software for creating and transforming `CProject`s. There are separate directories (`CTree`) for each article, which can staore raw files and transformed versions.
```
localhost:europepmc pm286$ pwd
/Users/pm286/workspace/appstract/europepmc
localhost:europepmc pm286$ tree | less

.
├── README.md
├── fmrirct
│   ├── PMC2443795
│   │   ├── eupmc_result.json
│   │   └── fulltext.xml
│   ├── PMC2474861
│   │   ├── eupmc_result.json
│   │   └── fulltext.xml
│   ├── PMC2557073
│   │   ├── eupmc_result.json
│   │   └── fulltext.xml
│   ├── PMC2630975
│   │   ├── eupmc_result.json
│   │   └── fulltext.xml
│   ├── PMC2646640
│   │   ├── eupmc_result.json
│   │   └── fulltext.xml
│   ├── PMC2654795
│   │   ├── eupmc_result.json
│   │   └── fulltext.xml
│   ├── PMC2734077
│   │   ├── eupmc_result.json
│   │   └── fulltext.xml
...
│   ├── PMC5915963
│   │   ├── eupmc_result.json
│   │   └── fulltext.xml
│   ├── eupmc_fulltext_html_urls.txt
│   └── eupmc_results.json
├── methods.sh
└── methods.xsl

```
(note `tree` is a useful UNIX facility for capturing directory listings)

`eupmc_result.json` is metadata for each article (will be useful later) and
`fulltext.xml` is the JATS-XML of each article. Not easy to read as no newlines. You may have an XML browser than helps.

`methods.xsl` and `methods.sh` are used now to transform...

## transform XML
We use XSLT stylesheets to extract the methods sections from the JATS-XML. JATS has a rich set of tags and we shall only use a few. Typical chunk:

```
<body>
<sec sec-type="introduction" id="s1">
<title>Introduction</title>
<p>Functional neuroimaging has enabled ...
</sec>
````

The section is tagged as "introduction" and we can search for this. Unfortunately the tags vary and many articles don't have `sec-type`. So far for methods we have found an XPath
```
@sect='methods|materials' or @sec-type='methods'
```
but we can update this as we discover other approaches (e.g. title='Methods and Materials').

### XSLT
To extract a methods section here is the XSLT (`methods.xsl`) - that's all we need!
```
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:h="http://www.w3.org/1999/xhtml">

	<xsl:template match="sec@sec-type">
		<xsl:if test="@sec-type='materials|methods' or @sec-type='methods'">
            <xsl:copy-of select="."/>
	     </xsl:if>
		 <xsl:message>SEC:<xsl:value-of select="@sec-type"/></xsl:message>
	</xsl:template> 
	
</xsl:stylesheet>
```
This finds any sections with `sec-type` attributes, and tests the values and copied those which are methods

### processing the CTrees
Bulk processing uses the `bash` script `methods.sh` to run `methods.xsl` over the whole `CProject`
```
cd fmri
for filename in ./PMC*; do
	echo $filename // $filename/sect.xml
	xsltproc -o ./$filename/sect.xml --novalid ../methods.xsl $filename/fulltext.xml 
done
cd ..

```
### output
part of console output:
```
...
transforming ./PMC5848117/fulltext.xml => ./PMC5848117/sect.xml
transforming ./PMC5857559/fulltext.xml => ./PMC5857559/sect.xml
transforming ./PMC5861091/fulltext.xml => ./PMC5861091/sect.xml
SEC:introduction
SEC:materials|methods
SEC:results
SEC:discussion
transforming ./PMC5865125/fulltext.xml => ./PMC5865125/sect.xml
transforming ./PMC5866875/fulltext.xml => ./PMC5866875/sect.xml
transforming ./PMC5871707/fulltext.xml => ./PMC5871707/sect.xml
SEC:conclusions
transforming ./PMC5888924/fulltext.xml => ./PMC5888924/sect.xml
transforming ./PMC5907295/fulltext.xml => ./PMC5907295/sect.xml
transforming ./PMC5910616/fulltext.xml => ./PMC5910616/sect.xml
SEC:supplementary-material
transforming ./PMC5915963/fulltext.xml => ./PMC5915963/sect.xml
SEC:intro
SEC:methods
SEC:results
SEC:discussion
SEC:conclusions
...
```
(many articles don't have `sec-type` attributes - will need to find other indicators).

The created sectioon files
```
localhost:europepmc pm286$ ls -lt */*/sect.xml
...
-rw-r--r--  1 pm286  staff    38605 11 May 11:35 fmrirct/PMC5712159/sect.xml
-rw-r--r--  1 pm286  staff    62642 11 May 11:35 fmrirct/PMC5713374/sect.xml
-rw-r--r--  1 pm286  staff   132572 11 May 11:35 fmrirct/PMC5716873/sect.xml
-rw-r--r--  1 pm286  staff    36901 11 May 11:35 fmrirct/PMC5729992/sect.xml
-rw-r--r--  1 pm286  staff   173023 11 May 11:35 fmrirct/PMC5754430/sect.xml
-rw-r--r--  1 pm286  staff    32045 11 May 11:35 fmrirct/PMC5758163/sect.xml
...
```



