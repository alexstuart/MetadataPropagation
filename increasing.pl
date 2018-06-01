#!/usr/bin/perl -n
#
BEGIN {
	$nlines = 0;
}

++$nlines;
chomp;
($time, $entityID) = split /\s+/;
print "$time $nlines\n";
