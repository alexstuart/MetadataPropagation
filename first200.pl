#!/usr/bin/perl -nw
#
# Takes output from propagate.pl, finds out when the first HTTP 200
# is given for each entityID.
#
# Output format: timestamp entityID
#
# Author: Alex Stuart, alex.stuart@jisc.ac.uk
my ($time, $entityID, $HTTPcode, $extra);

# Skip comment lines
if ( /^\s*#/ ) { next; }

# Split the input lines into components
chomp;
($time, $entityID, $HTTPcode, $extra) = split ',\s*', $_;
#print "time: $time; entityID: $entityID; HTTP code: $HTTPcode\n";

if ( defined $results{$entityID} ) { next; }
if ( $HTTPcode == 200 ) { $results{$entityID} = $time; } 

END {
	foreach (sort { $results{$a} cmp $results{$b} } keys %results) {
		print "$results{$_} $_\n";
	}
}

