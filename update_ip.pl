#!/usr/bin/perl

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
    if ( defined $ifh ) {
        while (<$ifh>) {
            chomp;
            $hostname = $_;
        }
        $ifh->close;
    }
    return $hostname;
}

sub get_recorded_ip {
    print "get_recorded_ip()\n" if $DEBUG;
    my $hostname = get_hostname();
    my $infile="$ENV{HOME}/info/${hostname}_ip";
    my $ip_address;
    my $ifh = IO::File->new( $infile, '<' );
    if ( defined $ifh ) {
        while (<$ifh>) {
            chomp;
            $ip_address = $_;
        }
        $ifh->close;
    }
    $ip_address =~ s/.* //;
    return $ip_address;
}

sub get_current_ip {
    print "get_current_ip()\n" if $DEBUG;
    my $infile = "$ENV{HOME}/.ifconfig";
    my $ifh = IO::File->new( $infile, '<' );
    die if ( !defined $ifh );

    my $ip_address;
    while (<$ifh>) {
        chomp;
        if ( m{Bcast} && m{\D*([\d\.]+).*} ) {
            $ip_address = $1;
            last;
        }
    }
    $ifh->close;
    return $ip_address;
}

sub write_ip_address {
    print "write_ip_address()\n" if $DEBUG;
    my $ip_address = shift;
    my $hostname = get_hostname();
    my $timestamp = timestamp();
    my $outfile="$ENV{HOME}/info/${hostname}_ip";
    my $ofh = IO::File->new( $outfile, '>>' );
    die if ( !defined $ofh );
    print $ofh "$timestamp $ip_address\n";
    $ofh->close;
    print "$timestamp $ip_address\n" if $DEBUG;
}

sub main {
    print "main()\n" if $DEBUG;
    my @argv = @_;
    my $current_ip = get_current_ip();
    print "current_ip {$current_ip}\n" if $DEBUG;
    if ( $current_ip =~ /\d+\.\d+\.\d+\.\d+/ ) {
        my $recorded_ip = get_recorded_ip() || '';
        print "recorded_ip {$recorded_ip}\n" if $DEBUG;
        if ( $current_ip ne $recorded_ip ) {
            write_ip_address($current_ip);
        }
    }
    return;
}

my $rc = ( main(@ARGV) || 0 );

exit $rc;

