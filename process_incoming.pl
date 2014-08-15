#!/usr/bin/perl

# TODO: more error checking

# purpose: automatically add tasks to task warrior from Dropbox folder

use strict;
use warnings;
use File::Copy;

my $other = 'Dropbox/other';
my $incoming = "$other/incoming";
my $completed = "$other/completed";

opendir(my $dh, $incoming) || die "can't opendir $incoming: $!";
my @todo = grep { /xdo/ && -f "$incoming/$_" } readdir($dh);
closedir $dh;

for my $file (@todo) {
    print "$file\n";
    open I, "<$incoming/$file" or die "Can't read $file: $!";
    my $line=<I>;
    close I;
    chomp $line;
    $line =~ s/[^\w\s]//g;
    $line =~ s/\s*xdo\s*//g;
    $line =~ s/\bx(\w+)/proj:$1/g; # allow easy add to project via xword
    print "    $line\n";
    open J, "task add due:today $line 2>&1 |" or die "Can't open pipe to task report";
    while(<J>) {
        print;
    }
    close J;
    move("$incoming/$file","$completed/$file") or die "Move failed: $!";
}

