#!/usr/bin/env perl
# Built from perl.t template
# purpose: get current Unix version

#    Copyright (C) 2020  David M. Bradford
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your u_option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see https://www.gnu.org/licenses/gpl.txt
#
#    The author, David M. Bradford, can be contacted at:
#    davembradford@gmail.com


use strict;
use warnings FATAL => 'all';

BEGIN { $| = 1 }

use File::Basename;
use Getopt::Long;

our $VERSION = '0.0.1';

my $PROG = basename($0);
my $ERR_EXIT = 2;

sub usage_top {
    warn "Usage: $PROG \n";
}

sub short_usage {
    usage_top();
    warn "Try '$PROG --help' for more information.\n";
}

sub errout {
    my $message = join( ' ', @_ );
    warn "$PROG: $message\n";
    short_usage();
    exit $ERR_EXIT;
}



sub usage {
    usage_top();
    warn <<EOF;
TEMPLATE do blah whatever thing
Example: $PROG 

  -h, --help    display this help text and exit
  -v, --version display version information and exit

EOF
    return;
}

sub do_short_usage {
    short_usage();
    exit $ERR_EXIT;
}

sub version {
    warn "$PROG $VERSION\n";
    return;
}

my $h        = 0;
my $help     = 0;
my $version  = 0;


Getopt::Long::Configure ("bundling");

my %options = (
    "help"   => \$help,
    "version" => \$version,

);

# Explicitly add single letter version of each option to allow bundling
my ($key, $value);
my %temp = %options;
while (($key,$value) = each %temp) {
    my $letter = $key;
    $letter =~ s/(\w)\w*/$1/;
    $options{$letter} = $value;
}
# Fix-ups from previous routine
$options{h} = \$h;

GetOptions(%options) or errout("Error in command line arguments");

# template: all code should be options-specific code

if    ($help)     { usage(); exit    }
elsif ($h)        { do_short_usage() }
elsif ($version)  { version(); exit  }
else { usage(); exit  }

use strict;
use warnings;

