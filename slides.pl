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
my $slide_num = 0;
my $screen_lines = 0;
my $dmb_note;

sub count_lines {
    my @lines = @_;
    my $total_lines = 0;
    for my $line (@lines) {
        while ($line =~ /\n/g) { $total_lines++ }
    }
    return $total_lines;
}

sub print_page {
    my @to_print = @_;
    my $num_lines = count_lines(@to_print);
    my $remainder = $screen_lines - $num_lines;
    print @to_print;
    print "\n" x $remainder;
    return;
}

sub show_current_slide {
    my $slide = sprintf("slide:%03d", $slide_num);
    my @output_lines = $dmb_note->search_note($slide);
    $output_lines[0] =~ s{$slide}{};
    print_page(@output_lines);
    return;
}

my %subs = (
    'h' => { does => 'Get Help',
            code => \&cmd_help },
    'q' => { does => 'Quit',
            code => sub { exit } },
    'd' => {
        does => 'Show Next Slide',
        code => sub {
            die Dumper($dmb_note);
        } },
    's' => {
        does => 'Show Next Slide',
        code => sub {
            $slide_num++;
            show_current_slide();
        } },
    'p' => {
        does => 'Show Previous Slide',
        code => sub {
            $slide_num--;
            $slide_num = 1 if $slide_num < 1;
            show_current_slide();
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

sub main {
    $screen_lines = shift;
    $file = shift;
    if ( !$file ) {
        die "Please provide a filename\n";
    }
    elsif ( ! -f $file ) {
        die "File '$file' was not found\n";
    }
    $dmb_note = DMB::Notes->new(
        file      => $file,
        title     => 1,
    );
    print "# of lines: $screen_lines\n";
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

my $rc = ( main(@ARGV) || 0 );

exit $rc;

