#!/usr/bin/perl
# purpose: functional (vs class) template

use strict;
use warnings FATAL => 'all';

use Data::Dumper;

sub function1 {
    print "I am function1\n";
}

sub main {
    my @argv = @_;
    print Dumper(\@argv);
    function1();
    return;
}

my $rc = ( main(@ARGV) || 0 );

exit $rc;

