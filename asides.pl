#!/usr/bin/perl -n

/<h2>([^<]*)<\/h2>/ and print "\n## $1\n";
/^\#\# (.*)/ and print $1;
if(/^<aside/ ... /<\/aside/) {
	 s/^<aside.*$//;
	 s/^<\/aside.*$//;
	print;
}
