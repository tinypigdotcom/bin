#!/usr/bin/perl

# put "p" in your path and then create links in the same directory to:
# 'f'
# 'fa'
# 'x'
# 'xa'
# 'z'
# Other external scripts:
# 'af'
# 'v'
# 'zdir'

# p - Dave's Project / File Manager

=head1 SYNOPSIS

    $ p d "My Vimfiles"
    $ p
    Projects:
    * d          My Vimfiles

    $ f v .vimrc
    $ f c .vim/colors/vividchalk.vim
    $ f b .bash_profile
    $ f
    Project: d (My Vimfiles)
    Current files:
    b .bash_profile                                      /home/dbradford
    v .vimrc                                             /home/dbradford
    c vividchalk.vim                                     /home/dbradford/.vim/colors

    $ f b # edit file assigned to "b" with vim

    $ fa  # edit all files in project with vim

    $ p m "My New Module"
    $ p
    Projects:
      d          My Vimfiles
    * m          My New Module

    $ f d DMB/lib/DMB.pm
    $ f t DMB/t/DMB.t
    $ f
    Project: m (My New Module)
    Current files:
    d DMB.pm                                             /home/dbradford/tmp/DMB/lib
    t DMB.t                                              /home/dbradford/tmp/DMB/t

    $ d t # cd to directory containing file represented by "t"

    $ x t "d m;make test"
    $ x t
    PERL_DL_NONLAZY=1 /usr/bin/perl.exe "-MExtUtils::Command::MM"
    "-MTest::Harness" "-e" "undef *Test::Harness::Switches; test_harness(0,
    'blib/lib', 'blib/arch')" t/*.t
    t/DMB.t .. ok
    All tests successful.
    Files=1, Tests=1,  0 wallclock secs ( 0.05 usr  0.02 sys +  0.05 cusr
    0.03 csys =  0.14 CPU)
    Result: PASS

    $ xa
    PERL_DL_NONLAZY=1 /usr/bin/perl.exe "-MExtUtils::Command::MM"
    "-MTest::Harness" "-e" "undef *Test::Harness::Switches; test_harness(0,
    'blib/lib', 'blib/arch')" t/*.t
    t/DMB.t .. ok
    All tests successful.
    Files=1, Tests=1,  0 wallclock secs ( 0.02 usr  0.02 sys +  0.01 cusr
    0.06 csys =  0.11 CPU)
    Result: PASS

    $ v
    d=/home/dbradford/tmp/DMB/lib/DMB.pm
    m=/home/dbradford/tmp/DMB/Makefile
    t=/home/dbradford/tmp/DMB/t/DMB.t

    $ cat $t >>$d

=head1 DESCRIPTION

Dave's Project / File Manager is designed to make managing sets of files easier. Files can be grouped into projects and then each file can be accessed with a simple command: f [space][letter representing file] [ENTER]

=head1 INSTALLATION

Put "p" in your C<$PATH> and then create links to p in the same directory as:

  f     # file edit
  fa    # edit all files
  x     # execute command
  xa    # execute all commands
  z     # get help
  zdir  # get directory of file

Separate scripts, put somewhere in C<$PATH>
  d     # change to file directory
  v     # set shell variables for file shortcuts

Add the following lines to your C<.bash_profile>:
  alias d='. d'
  alias v='. v'

=head1 AUTHOR

David M. Bradford, E<lt>davembradford@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by David M. Bradford

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

use strict;
use warnings;

use Clone qw(clone);
use Cwd;
use Data::Dumper;
use File::Basename;
use Storable;
use YAML qw(LoadFile DumpFile);

my $PROG = $0;
($PROG) = ( $PROG =~ m!.*/(.*)! );

if ( defined $ARGV[0] ) {
    if ( $ARGV[0] eq '--help' or $ARGV[0] eq '-?' or $ARGV[0] eq '-h' ) {
        $PROG = 'z';
    }
    elsif ( $PROG eq 'p' ) {
        if ( $ARGV[0] eq 'cp' or $ARGV[0] eq 'mv' ) {
            $PROG = shift @ARGV;
        }
    }
}

my ( $current, $data, $cmds, $files );

my $legacy_infile = "$ENV{HOME}/.prc";
my $infile        = "$ENV{HOME}/.pyaml";
my $VERSION       = '0.2';

my @ident = ( 0 .. 9, 'a' .. 'z', 'A' .. 'Z' );

my %ident;

@ident{@ident} = (1) x @ident;

if ( -e $infile ) {
    $data = LoadFile($infile);
}
elsif ( -r $legacy_infile ) {
    $data = retrieve($legacy_infile);
}
else { $data = {} }
init();

# structure of data
#################################################################
#$VAR1 = { 'current' => 't',
#          'projects' => { 'pa' => { 'files' => { 'a' => '/home/dbradford/t3s/api_test.pl',
#                                                 'o' => '/home/dbradford/bin/onetime',
#                                                 'U' => '/opt/manfred/lib/Manfred/SimmCreate.pm' },
#                                    'commands' => { 'a' => { 'cmd' => '/home/dbradford/t3s/api_test.sh',
#                                                             'label' => '' },
#                                                    't' => { 'cmd' => './api_post.sh',
#                                                             'label' => '' } },
#                                    'label' => 'Manfred Test Gauntlet (TM)'
#                                  },
#                          'pad' => {etc},
#                        }
#        };

sub pfreeze {
    envwrite();
    eval { DumpFile( $infile, $data ); };
    print "Error writing to file: $@" if $@;
}

sub envwrite {
    open O, ">$ENV{HOME}/.penv" or die;
    for ( "a" .. "z", "A" .. "Z" ) {
        my $file = $files->{$_};
        $file //= '';
        print O "export $_=$file\n";
    }
    for ( keys %$files ) {
        my $file = $files->{$_};
        $file //= '';
        print O qq{echo "$_=$file"\n};
    }
}

sub fix {
    my $i = shift;
    for ($i) {
        s/\n$//m;
        s/^    //mg;
    }
    return $i;
}

sub init {
    $current = $data->{current};
    if ( !$data->{projects}->{$current}->{files} ) {
        $data->{projects}->{$current}->{files} = {};
    }
    if ( !$data->{projects}->{$current}->{commands} ) {
        $data->{projects}->{$current}->{commands} = {};
    }
    $files = $data->{projects}->{$current}->{files};
    $cmds  = $data->{projects}->{$current}->{commands};
}

sub del {
    my ( $ar, $dr ) = @_;
    for ( @{$ar} ) {
        delete $dr->{$_};
    }
    pfreeze();
}

sub fullpath {
    my @files = @_;
    my $pwd   = cwd();
    my $nwd;
    for (@files) {
        if (m!(.*)/(.*)!) {
            chdir $1 or next;
            $nwd = cwd();
            $_   = "$nwd/$2";
            chdir $pwd or die "Couldn't change dir back to $pwd.";
        }
        else {
            $_ = "$pwd/$_";
        }
    }
    chdir $pwd or die "Couldn't change dir back to $pwd.";
    return @files;
}

sub derange {
    my ( $pattern, $hashref ) = @_;

    return if !defined $pattern;

    return $pattern if ( $pattern !~ /-/ );

    $pattern =~ s/(.)-(.)/&{
        sub {
            my @b = @_;
            my $a;
            for ( $b[0]..$b[1] ) {
                $a .= $_ if $hashref->{$_};
            }
            return $a
        }
    }($1,$2)/eg;

    return $pattern;
}

sub pcopy {
    my ( $from, $to, $delete_flag ) = @ARGV;
    $data->{projects}->{$to} = clone( $data->{projects}->{$from} );
    if ( $delete_flag ) {
        delete $data->{projects}->{$from};
    }
    $data->{current} = $to;
    $PROG            = 'f';
    @ARGV            = ();
    init();
    pfreeze();
}

if ( $PROG eq 'cp' ) {
    pcopy( $ARGV[0], $ARGV[1] );
}

if ( $PROG eq 'mv' ) {
    my $delete_flag = 1;
    pcopy( $ARGV[0], $ARGV[1], $delete_flag );
}

if ( $PROG eq 'zdir' ) {
    my $key = $ARGV[0];

    if ($key) {
        my $file = $files->{$key};
        if ($file) {
            print dirname($file);
        }
        else {
            print STDERR "Can't make sense of $key.\n";
            print STDERR "It is a file you don't have read permission on, \n";
            print STDERR "or labels that don't have associated files.\n";
        }
    }
}

if ( $PROG eq 'p' ) {
    my $arg = $ARGV[0];
    $arg //= '';
    my ( $cmd, $proj ) = ( $arg =~ /(.)(.*)/ );
    if ( defined $cmd && $cmd eq '-' ) {
        if ( $proj eq $current ) {
            print STDERR "Can't remove current project.\n";
        }
        else {
            delete $data->{projects}->{$proj};
            pfreeze;
        }
    }
    elsif ( !$arg ) {
        print "Projects:\n";
        for ( sort keys %{ $data->{projects} } ) {
            print( ( $_ eq $current ) ? '*' : ' ' );
            my $label = $data->{projects}->{$_}->{label};
            $label //= '';
            printf " %-10s %-15s\n", $_, $label;
        }
    }
    else {
        $data->{current} = $arg;
        $data->{projects}->{$arg}->{label} = $ARGV[1] if ( $ARGV[1] );
        init();
        @ARGV = ();
        $PROG = 'f';
        @ARGV = ();
        pfreeze();
    }
}

if ( $PROG eq 'f' or $PROG eq 'fa' ) {
    my $na = scalar @ARGV;
    my @x  = @ARGV;

    if ( $na == 1 or $PROG eq 'fa' ) {
        my $f  = '';
        my $f1 = 0;
        my @l  = split //, derange( $x[0], $files );
        if ( $PROG eq 'fa' ) { @l = keys %{$files} }
        if ( $l[0] eq '-' ) {    # Delete labels
            shift @l;
            del( \@l, $files );
        }
        else {                   # Edit files
            for (@l) {
                if ( $files->{$_} ) {
                    $f .= "$files->{$_} ";
                }
                else { ++$f1 }
            }
            if ( !$f1 ) {
                exec "vim $f";
            }
            else {
                print STDERR "Can't make sense of $x[0].\n";
                print STDERR
                  "It is a file you don't have read permission on, \n";
                print STDERR "or labels that don't have associated files.\n";
            }
        }
    }
    elsif ( $na == 2 and $x[0] ne ',' ) {    # Add file to specific label
        my ($file) = fullpath( $x[1] );
        if ( $ident{ $x[0] } ) {
            if ( -r $file ) {
                $files->{ $x[0] } = $file;
                pfreeze();
            }
            else {
                print STDERR "Can't read: $file\n";
            }
        }
        else {
            print STDERR "Invalid identifier: $x[0]\n";
            print STDERR "Use one of: @ident\n";
        }
    }
    elsif ( defined $x[0] && $x[0] eq ',' ) {    # Add files to generic label
        shift @x;
        for (@x) {
            my ($file) = fullpath($_);
            if ( -r $file ) {
                for my $i (@ident) {
                    if ( !exists $files->{$i} ) {
                        $files->{$i} = $file;
                        last;
                    }
                }
            }
            else {
                print STDERR "Can't read: $file\n";
            }
        }
        pfreeze();
    }
    else {    # Error/Print list of files
        if ( $na != 0 ) {
            print STDERR "Bad arguments.\n";
        }
        my $label = $data->{projects}->{$current}->{label};
        $label //= '';
        print "Project: $current ($label)\n";
        print "Current files:\n";

        my %sorted;
        for ( keys %$files ) {
            my ( $a, $b ) = ( $files->{$_} =~ m!(.*)/(.*)! );
            my $i = lc($b) . lc($a);
            ( $sorted{$i}->{path} ) = ( $a =~ /(.{1,70})/ );
            ( $sorted{$i}->{file} ) = ( $b =~ /(.{1,50})/ );
            $sorted{$i}->{let} = $_;
        }

        for ( sort keys %sorted ) {
            printf "%-1s %-50s %-70s\n", $sorted{$_}->{let},
              $sorted{$_}->{file}, $sorted{$_}->{path};
        }
    }
}

if ( $PROG eq 'x' or $PROG eq 'xa' ) {
    my $na    = scalar @ARGV;
    my @a     = @ARGV;
    my $f1    = 0;
    my $f2    = 0;
    my $flist = '';
    my $f     = '';

    my @l = split //, derange( $a[0], $cmds );

    my $g = $l[0];
    if ( $g eq '.' or $g eq '-' ) { shift @l }

    for (@l) {
        if ( !$cmds->{$_} ) { ++$f1 }
    }
    if ( $a[1] =~ /^-(.*)/ ) {
        $flist = $1;
    }

    if ( $na == 1 or $PROG eq 'xa' or $flist ) {
        my $f = '';
        if ( $PROG eq 'xa' ) { @l = keys %{$cmds} }
        if ( $g eq '-' ) {    # Delete labels
            del( \@l, $cmds );
        }
        elsif ( $g eq '.' ) {    # Edit commands
            if ( !$f1 ) {
                for (@l) {
                    open OUT, ">/tmp/c.$$.$_"
                      or die "Can't open temp file: /tmp/c.$$.$_";
                    print OUT "$cmds->{$_}->{label}: $cmds->{$_}->{cmd}\n";
                    print OUT
"# The label precedes the colon above and my be edited freely\n";
                    print OUT "# As long as the colon is left intact.\n";
                    print OUT
"# Only the first line is read. Don't add more lines to this file.\n";
                    close OUT;
                    $f .= "/tmp/c.$$.$_ ";
                }

# Why is vi returning 1 on a good exit?
#                if(!system("vim $f")) { # not(!) because in Unix 0 status is good
                system("vim $f");
                for (@l) {
                    my $m;
                    open OUT, "</tmp/c.$$.$_"
                      or die "Can't open temp file: /tmp/c.$$.$_";
                    chomp( $m = <OUT> );
                    if ( $m =~ /(.*):\s*(.*)/ ) {
                        $cmds->{$_}->{label} = $1;
                        $cmds->{$_}->{cmd}   = $2;
                    }
                    else {
                        print STDERR
                          "Bad format on file for command labeled $_\n";
                    }
                    close OUT;
                    unlink "/tmp/c.$$.$_";
                }
                pfreeze();

                #                }
            }
            else {
                print STDERR "Bad labels in $a[0].\n";
            }
        }
        else {    # Run commands
            my $f = '';
            if ($flist) {

                my @m = split //, derange( $flist, $files );
                for (@m) {
                    if ( $files->{$_} ) {
                        $f .= "$files->{$_} ";
                    }
                    else { ++$f2 }
                }
            }
            if ($f2) {
                print STDERR "Can't make sense of $flist.\n";
                print STDERR
                  "It is a file you don't have read permission on, \n";
                print STDERR "or labels that don't have associated files.\n";
            }
            elsif ( !$f1 ) {
                for (@l) {
                    print "$cmds->{$_}->{cmd} $f\n";
                    if ( system("/bin/sh -c '$cmds->{$_}->{cmd} $f'") ) {
                        print STDERR
"An error occurred while running: $cmds->{$_}->{cmd}\n";
                        last;
                    }
                }
            }
            else {
                print STDERR "Bad labels in $a[0].\n";
            }
        }
    }
    elsif ( $na == 2 or $na == 3 ) {
        if ( $ident{ $a[0] } ) {    # Add command to specific label
            $cmds->{ $a[0] }->{cmd} = $a[1];
            $cmds->{ $a[0] }->{label} = $a[2] || '';
            pfreeze;
        }
        elsif ( $a[0] eq ',' ) {    # Add command to generic label
            for my $i (@ident) {
                if ( !exists $cmds->{$i}->{cmd} ) {
                    $cmds->{$i}->{cmd} = $a[1];
                    $cmds->{$i}->{label} = $a[2] || '';
                    last;
                }
            }
            pfreeze;
        }
        else {                      # Error
            print STDERR "Invalid identifier: $a[0]\n";
            print STDERR "Use one of: @ident\n";
        }
    }
    else {                          # Print list of commands
        if ( $na != 0 ) {
            print STDERR "Bad arguments.\n";
        }
        print "Project: $current\n";
        print "Current commands:\n";
        for (
            sort {
                my $c = lc $a;
                my $d = lc $b;
                if   ( $c eq $d ) { $b cmp $a }
                else              { $c cmp $d }
            } keys %{$cmds}
          )
        {
            printf "%1s: %-20s %-15s\n", $_, $cmds->{$_}->{label},
              $cmds->{$_}->{cmd};
        }
    }
}

if ( $PROG eq 'z' ) {
    print fix(<<"    EOF"), "\n";
    Dave's Development System v$VERSION
    Help commands:
                   z  - this listing
    Organization commands:
                   f  - manage files
                      examples:
                      show list of files:    \$ f
                      edit file 1, 3, and L: \$ f 13L
                      edit all files:        \$ fa
                      add file to the list : \$ f , /tmp/a.dmb /etc/hosts /etc/passwd
                      add file with label L: \$ f L /tmp/a.dmb
                      remove file 1, 3, L  : \$ f -13L
                   x  - manage commands (same basic format as f)
                      examples:
                      show list of cmds:     \$ x
                      run cmd 1, 3, and L:   \$ x 13L
                      edit cmd 1, 3, and L:  \$ x .13L
                      edit all cmds:         \$ xa
                      add cmd to the list :  \$ x , 'echo hey' 'Optional Label'
                         NOTE: surround command with quotes
                      add cmd with label L:  \$ x L 'echo howdy; echo there' 'Optional Label'
                      remove cmd 1, 3, L  :  \$ x -13L
                   p  - change project/view list of projects
                      show project list:     \$ p
                      switch to project:     \$ p myproj
                      remove project:        \$ p -myproj
    Current project: $data->{'current'}
    EOF
}
