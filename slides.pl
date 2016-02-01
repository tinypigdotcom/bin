#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Data::Dumper;
use DMB::Tools ':all';

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


