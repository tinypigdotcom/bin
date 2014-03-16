#!/usr/bin/perl

use strict;
use warnings;

open I, "task now |" or die "Can't open pipe to task";

while (<I>) {
    next if !/^\s*(\d+)\s+/ || /^\d+\s+tasks/;
    chomp;
    my $task_number = $1;
    my $task_line = $_;

    print "\n\n$task_line --- Complete #$task_number (x/i/p/[do nothing]/q)? ";
    my $answer = <>;
    chomp $answer;
    if($answer eq 'x') {
        open J, "task $task_number done |" or die "Can't open pipe to task report";
        while(<J>) {
            print;
        }
    }
    elsif ($answer eq 'i') {
        open J, "echo n | task $task_number rc.confirmation:no delete |" or die "Can't open pipe to task report";
        while(<J>) {
            print;
        }
    }
    elsif ($answer eq 'p') {
        open J, "echo n | task $task_number modify +postponed |" or die "Can't open pipe to task report";
        while(<J>) {
            print;
        }
    }
    elsif ($answer eq 'q') {
        exit;
    }
    else {
        print "nothing done";
    }
    print "\n";
}

