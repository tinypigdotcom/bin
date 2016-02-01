#!/usr/bin/perl
# purpose: a command-line presentation tool

use strict;
use warnings FATAL => 'all';

use Data::Dumper;
use DMB::Tools ':all';

our $VERSION = '0.0.1';

sub function1 {
    my ($lines) = @_;
    print "# of lines: $lines\n";
    return;
}

sub main {
    my @argv = @_;
    function1(@argv);
    return;
}

my $rc = ( main(@ARGV) || 0 );

exit $rc;


