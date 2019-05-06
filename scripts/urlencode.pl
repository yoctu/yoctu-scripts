#!/usr/bin/env perl

use strict;
use Getopt::Std;
use Getopt::Long;
use File::Basename;
use URI::Escape;

Getopt::Long::Configure(qw{no_auto_abbrev no_ignore_case_always});

my $VERSION = "0.1";
my $OPTS = "dh";
my ( $softname, $path, $suffix ) = fileparse( $0, qr{\.[^.]*$} );
my $USAGE = "$softname$suffix -f [FILE] -c [CHANNEL] [-h HELP] OPTS[$OPTS]";
my $HELP =<<USAGE;

     Options:

	-h|--help	Help

     Usage:

         $USAGE
     
USAGE

# We could use die instead, but i like this method
sub _quit {
    my ($retCode, $msg) = @_;

    print "$msg\n";
    exit $retCode    
};

my $options = {};

GetOptions(
    'help|h' 	 	=> \$options->{help},
    'decode|d'          => \$options->{urldecode}
);

$options->{urlencode} = 1 if !defined($options->{urldecode});

_quit(0,$HELP) if defined($options->{help});

my $str = do { local $/; <STDIN> };
$str =~ s/\+/%20/g;

if ( defined($options->{urlencode}) ) {
    print uri_escape($str);
} elsif ( defined($options->{urldecode})) {
    print uri_unescape($str);
}
