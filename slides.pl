#!/usr/bin/perl
# purpose: a command-line presentation tool

use strict;
use warnings FATAL => 'all';

use Data::Dumper;
use DMB::Notes;
use DMB::Tools ':all';
use Term::ReadLine;

our $VERSION = '0.0.1';

my $term;
my $file;
my %subs = (
    'h' => { does => 'Get Help',
            code => \&cmd_help },
    'q' => { does => 'Quit',
            code => sub { exit } },
    's' => {
        does => 'Get Slide',
        code => sub {
            my $dmb_note = DMB::Notes->new(
                file      => $file,
                title     => 1,
            );
            my @output_files = $dmb_note->search_note('page:01');
            print @output_files;
        } },
);

sub cmd_help {
    for ( sort { $a cmp $b } keys %subs ) {
        printf "%-3s %-34s\n", $_, $subs{$_}->{does};
    }
}

sub add_history {
    $term->addhistory($_[0]);
}

sub function1 {
    my $lines = shift;
    $file = shift;
    if ( !$file ) {
        die "Please provide a filename\n";
    }
    elsif ( ! -f $file ) {
        die "File '$file' was not found\n";
    }
    print "# of lines: $lines\n";
    $term = Term::ReadLine->new('slides');
    $term->MinLine(undef); # disable autohistory
    my $prompt = "slides> ";
    while ( defined( my $line = $term->readline($prompt) ) ) {
        $line ||= 's';
        chomp $line;
        $line =~ m{(\S+)\s?};
        my $first_word = $1 || '';
        if ($subs{$first_word}) {
            my $coderef = $subs{$first_word}->{code};
            $coderef->($line);
        }
        add_history($line) if $line =~ /\S/;
    }
    return;
}

sub main {
    my @argv = @_;
    function1(@argv);
    return;
}

my $rc = ( main(@ARGV) || 0 );

exit $rc;

