#!/usr/bin/perl
# purpose: indicate ability to communicate
# VERSION: 0.0.1

use strict;
use warnings FATAL => 'all';

use IO::File;

my $DEBUG = 0;

sub timestamp {
    my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
    $mon++;
    $year += 1900;
    return sprintf("%04s/%02s/%02s %02s:%02s:%02s",$year,$mon,$mday,$hour,$min,$sec);
}

sub get_hostname {
    print "get_hostname()\n" if $DEBUG;
    my $infile = "$ENV{HOME}/.hostname";
    my $hostname;
    my $ifh = IO::File->new( $infile, '<' );
    die if ( !defined $ifh );
    while (<$ifh>) {
        chomp;
        $hostname = $_;
    }
    $ifh->close;
    return $hostname;
}

sub write_heartbeat {
    print "write_heartbeat()\n" if $DEBUG;
    my $hostname = get_hostname();
    my $timestamp = timestamp();
    my $outfile = "$ENV{HOME}/info/${hostname}_heartbeat";
    my $ofh = IO::File->new( $outfile, '>>' );
    die if ( !defined $ofh );
    print $ofh "$timestamp\n";
    $ofh->close;
    print "$timestamp\n" if $DEBUG;
}

sub main {
    print "main()\n" if $DEBUG;
    my @argv = @_;
    write_heartbeat();
    return;
}

my $rc = ( main(@ARGV) || 0 );

exit $rc;

