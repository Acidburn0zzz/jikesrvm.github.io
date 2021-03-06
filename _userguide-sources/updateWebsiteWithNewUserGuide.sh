#!/bin/sh

# Builds a new userguide and updates the website.
# Note: error handling is practically non existent.

# To inspect the result, you will need to build a local
# version of the website with Jekyll.

# FIXME images are in the wrong place for Jekyll.

mainFile="userguide.tex"
websiteFile="index.tex"

tmpDir="userguide-for-website-build-tmp"
frontmatterFile="jekyll-frontmatter"
tmpFile="cat-tmp-html"
sedTmpFile="sed-tmp-html"
sedTmpFileImage="sed-tmp-html-image"
sedTmpFileImageTakeTwo="sed-tmp-html-image-take-two"
sedTestFile="sed-test-file"

# Copy files to build dir
rm -rf $tmpDir
mkdir $tmpDir
cp * $tmpDir
cp -r images/ $tmpDir
# Copy base CSS
cp ../css/custom.css $tmpDir

cd $tmpDir

# Clean unneeded files
rm *.sh
rm README

# Rename TeX source file to get an index.html for the website
mv $mainFile $websiteFile

# Generate user guide
htlatex $websiteFile "html-website.cfg,xhtml,charset=utf8,2" " -cunihtf -utf8" " -cvalidate"

# Add Jekyll frontmatter
for htmlFile in *.html
do
  cat $frontmatterFile $htmlFile > $tmpFile
  # Note: directory must be manually inserted
  # Note: : is excluded to make sure that we only match relative links,
  #  i.e. href="/something/bla.html" and not something like href="http://example.com"
  sed 's|href=\"\([^:]*\)\.html#|href=\"/UserGuide/\1\/index.html#|g' $tmpFile > $sedTmpFile
  sed 's|src=\"\(.*\)\.png|src=\"/UserGuide/\1\.png|g' $sedTmpFile > $sedTmpFileImage
  sed 's|src=\"\(.*\)\.jpg|src=\"/UserGuide/\1\.jpg|g' $sedTmpFileImage > $sedTmpFileImageTakeTwo
  mv $sedTmpFileImageTakeTwo $htmlFile
done

# Copy new CSS
rm ../../css/index.css
cp index.css ../../css/

# Remove output that belongs somewhere else
rm *.css
# Remove temporary tex files
rm *.log *.aux *.dvi *.4ct *.idv *.lg *.tmp *.xref *.out *.toc *.syncte* *.4tc
# Remove output files not intended for website
rm *.pdf
# Remove source files
rm *.tex*
rm *.cfg
rm $frontmatterFile

rm $tmpFile
rm $frontmatterFile
rm $sedTmpFile
rm $sedTmpFileImage
rm $sedTestFile

# Update 
cd ..
# Note directory is hardcoded because we're hardcoding it into the sed expression above
rm -rf ../UserGuide/
mv $tmpDir ../UserGuide/
