#!/usr/bin/perl -w
#
# Script to measure metadata propagation
#
# Author: Alex Stuart, alex.stuart@jisc.ac.uk
#
$| = 1;
use Getopt::Long;

my $interval_d = 300; # 5 minutes default repeat interval

sub usage {
        my $message = shift(@_);
        if ($message) { print "\n$message\n"; }
	
	print <<EOF;

	usage: $0 [-h] [-v] [-i <interval>] -r <RequestInitiator> \\
		[-f <file> | -e <IdP entityID> [-e <IdP entityID> ...]]

	Script to measure metadata propagation

	-r <RequestInitiator> - RequestInitiator to use
	-i <interval>         - number of seconds between repeats (default is $interval_d)

	-e <IdP entityID>     - 1 or more IdP entityIDs to check (multiple -e options allowed)
        -f <file>             - read list of entityIDs from file, one entityID per line

	-h - print this help text and exit
	-v - be verbose

	This script issues curl commands to the RequestInitiator, asking for an AuthnRequest
	to be sent to the specified IdP entityID(s). The IdPs are presumed to be Shibboleth v3
	so the HTTP status code of the request is:

	200 (OK) if the SP recognises both the IdP entityID and the AssertionConsumerService endpoint
	500 (Server Error) if the AssertionConsumerService endpoint isn't recognised (jetty hosted)
	400 (Bad Request) if the AssertionConsumerService endpoint isn't recognised (http+tomcat)

	The output of the script is a series of lines: timestamp, entityID, return code

	The way to measure propagation time is to:
	1) Register an SP's metadata
	2) Configure the SP to have an AssertionConsumerService endpoint that is not in metadata
	3) Set this script running. You should find the output is HTTP status 400/500
	4) Register the new endpoint
	5) Watch the output as the IdP recognises the SP's new endpoint (and HTTP status goes to 200)

EOF
}

my $help;
my $RequestInitiator;
my $verbose;
my @entityIDs;
my $interval;
my $file;
GetOptions( 	"help" => \$help,
		"requestinitiator=s" => \$RequestInitiator,
		"verbose" => \$verbose,
		"entityIDs=s" => \@entityIDs,
		"interval=i" => \$interval,
		"file=s" => \$file
            );

if ( $help ) {
    usage;
    exit 0;
}

if ( ! $RequestInitiator ) {
	usage( "ERROR: must supply a RequestInitiator with -r" );
	exit 1;
}

if ( ! $interval ) { $interval = $interval_d; }

#
# Populate array of entityIDs either from multiple -e options or from the file specified by -f
#
if ( @entityIDs && $file ) { 
	usage( "ERROR: cannot have both -e and -f options to define entityIDs" );
	exit 1;
}
if ( $file ) {
	open(ENTITYIDS, "<", "$file") || die "Cannot open file of entityIDs for reading, $file";
	while(<ENTITYIDS>) {
		if (/^\s*#/) { next; }
		chomp;
		s/,.*//;
		push @entityIDs, $_;
	}
	close(ENTITYIDS);
}
if ( $#entityIDs == -1 ) {
	usage( "ERROR: must specify at least one entityID using -e or -f options" );
	exit 1;
}

$verbose && print "Script running in verbose mode\n";
$verbose && print "RequestInitiator: $RequestInitiator\n";
if ( $verbose ) { foreach (@entityIDs) { print "entityID: $_\n"; } }
$verbose && print "Repeat interval: $interval\n";

sub doTheThing {
	my $RequestInitiator = shift;
	my $entityID = shift;
	my $now;

	$encodedID = $entityID;
	$encodedID =~ s!:!%3A!g;
	$encodedID =~ s!/!%2F!g;

	$verbose && print "Checking $entityID\n";

	open(TIME, 'date -u "+%Y-%m-%dT%H:%M:%SZ" |') || warn "cannot find date";
	while (<TIME>) { chomp; $now .= $_; }
	close(TIME);
	$verbose && print "$now\n";
        # curl flags are ordered so that -o and -w can be omitted when cutting and pasting output from -v
	$theCommand = 'curl --connect-timeout 3 -k --silent -L -c /tmp/cookies.txt ' . $RequestInitiator . '?entityID=' . $encodedID .
		' -o /dev/null -w "' . $now. ', ' . $entityID . ', %{http_code}\n"';
	$verbose && print "$theCommand\n";
	open (FILE, "$theCommand |") || warn "Cannot get the curl command to work";
	while (<FILE>) { print; }
	close (FILE);
}

while (1) {
	foreach $entityID (@entityIDs) { doTheThing( $RequestInitiator, $entityID ); }
	sleep $interval;
}
