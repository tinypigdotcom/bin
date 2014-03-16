#!/usr/bin/perl

use strict;
use warnings;

open I, "task +postponed |" or die "Can't open pipe to task";

while (<I>) {
    next if !/^\s*(\d+)\s+/ || /^\d+\s+tasks$/;
    chomp;
    my $task_number = $1;
    my $task_line = $_;

    open J, "echo n | task $task_number modify -postponed |" or die "Can't open pipe to task report";
    while(<J>) {
        print;
    }
}

