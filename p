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
use warnings FATAL => 'all';

use Carp;
use Clone qw(clone);
use Cwd;
use Data::Dumper;
use File::Basename;
use IO::File;
use Storable;
use Hash::Util qw(lock_keys);

our $VERSION = '0.2';
our $VAR1;

exit main( $0, @ARGV );

sub pfreeze {
    my ($g) = @_;
    envwrite($g);
    dump_write($g);
    return;
}

sub dump_read {
    my ($g) = @_;

    my $ifh = IO::File->new($g->{infile}, '<');
    croak if (!defined $ifh);

    my $contents = do { local $/; <$ifh> };
    $ifh->close;

    $g->{data} = eval $contents; ## no critic
    if ( !defined $g->{data} ) {
        croak "failed eval of dump";
    }
    return;
}

sub dump_write {
    my ($g) = @_;

    my $ofh = IO::File->new($g->{infile}, '>');
    croak if (!defined $ofh);

    print $ofh Dumper($g->{data});
    $ofh->close;
    return;
}

sub envwrite {
    my ($g) = @_;

    my $ofh = IO::File->new( "$ENV{HOME}/.penv", '>' );
    croak if ( !defined $ofh );

    for ( "a" .. "z", "A" .. "Z" ) {
        my $file = $g->{files}->{$_};
        $file //= '';
        print $ofh "export $_=$file\n";
    }

    for ( keys %{ $g->{files} } ) {
        my $file = $g->{files}->{$_};
        $file //= '';
        print $ofh qq{echo "$_=$file"\n};
    }

    $ofh->close;
    return;
}

sub fix {
    my ($n,$i) = @_;
    my $spaces = ' ' x $n;
    for ($i) {
        s/\n$//m;
        s/^$spaces//mg;
    }
    return $i;
}

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

sub init {
    my ($g) = @_;
    $g->{current} = $g->{data}->{current};
    if ( !$g->{data}->{projects}->{ $g->{current} }->{files} ) {
        $g->{data}->{projects}->{ $g->{current} }->{files} = {};
    }
    if ( !$g->{data}->{projects}->{ $g->{current} }->{commands} ) {
        $g->{data}->{projects}->{ $g->{current} }->{commands} = {};
    }
    $g->{files} = $g->{data}->{projects}->{ $g->{current} }->{files};
    $g->{cmds}  = $g->{data}->{projects}->{ $g->{current} }->{commands};
    return;
}

sub del {
    my ( $ar, $dr, $g ) = @_;
    for ( @{$ar} ) {
        delete $dr->{$_};
    }
    pfreeze($g);
    return;
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
            chdir $pwd or croak "Couldn't change dir back to $pwd.";
        }
        else {
            $_ = "$pwd/$_";
        }
    }
    chdir $pwd or croak "Couldn't change dir back to $pwd.";
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
    my ($g) = @_;
    my ( $from, $to, $delete_flag ) = @{ $g->{args} };
    my $projects = $g->{data}->{projects};

    $projects->{$to} = clone( $projects->{$from} );
    if ($delete_flag) {
        delete $projects->{$from};
    }
    $g->{data}->{current} = $to;
    $g->{prog} = 'f';
    @{ $g->{args} } = ();
    init($g);
    pfreeze($g);
    return;
}

sub zdir {
    my ($g) = @_;
    my $key = $g->{args}->[0];

    return if ( !$key );

    my $file = $g->{files}->{$key};

    if ( !$file ) {
        print STDERR fix(8,<<"        EOF"), "\n";
        Can't make sense of $key
        It is a file you don't have read permission on,
        or labels that don't have associated files.
        EOF
        return;
    }

    print dirname($file);
    return;
}

sub func_p {
    my ($g) = @_;
    my $arg = $g->{args}->[0];
    $arg //= '';
    my $projects = $g->{data}->{projects};

    my ( $cmd, $proj ) = ( $arg =~ /(.)(.*)/ );
    if ( defined $cmd && $cmd eq '-' ) {
        if ( $proj eq $g->{current} ) {
            print STDERR "Can't remove current project.\n";
        }
        else {
            delete $projects->{$proj};
            pfreeze($g);
        }
    }
    elsif ( !$arg ) {
        print "Projects:\n";
        for ( sort keys %{ $projects } ) {
            print( ( $_ eq $g->{current} ) ? '*' : ' ' );
            my $label = $projects->{$_}->{label};
            $label //= '';
            printf " %-10s %-15s\n", $_, $label;
        }
    }
    else {
        $g->{data}->{current} = $arg;
        $projects->{$arg}->{label} = $g->{args}->[1]
          if ( $g->{args}->[1] );
        init($g);
        $g->{prog} = 'f';
        @{ $g->{args} } = ();
        pfreeze($g);
    }
    return;
}

sub func_f {
    my ($g) = @_;
    my $na  = scalar @{ $g->{args} };
    my @x   = @{ $g->{args} };

    if ( $na == 1 or $g->{prog} eq 'fa' ) {
        my $f  = '';
        my $f1 = 0;

        my $tmp = derange( $x[0], $g->{files} );
        my @l = split //, ( defined($tmp) ? $tmp : '' );

        if ( $g->{prog} eq 'fa' ) { @l = keys %{ $g->{files} } }
        if ( $l[0] eq '-' ) {    # Delete labels
            shift @l;
            del( \@l, $g->{files}, $g );
        }
        else {                   # Edit files
            for (@l) {
                if ( $g->{files}->{$_} ) {
                    $f .= "$g->{files}->{$_} ";
                }
                else { ++$f1 }
            }
            if ( !$f1 ) {
                exec "$ENV{EDITOR} $f";
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
        if ( $g->{h_ident}->{ $x[0] } ) {
            if ( -r $file ) {
                $g->{files}->{ $x[0] } = $file;
                pfreeze($g);
            }
            else {
                print STDERR "Can't read: $file\n";
            }
        }
        else {
            print STDERR "Invalid identifier: $x[0]\n";
            print STDERR 'Use one of: ' . join( '', @{ $g->{a_ident} } ) . "\n";
        }
    }
    elsif ( defined $x[0] && $x[0] eq ',' ) {    # Add files to generic label
        shift @x;
        for (@x) {
            my ($file) = fullpath($_);
            if ( -r $file ) {
                for my $i ( @{ $g->{a_ident} } ) {
                    if ( !exists $g->{files}->{$i} ) {
                        $g->{files}->{$i} = $file;
                        last;
                    }
                }
            }
            else {
                print STDERR "Can't read: $file\n";
            }
        }
        pfreeze($g);
    }
    else {    # Error/Print list of files
        if ( $na != 0 ) {
            print STDERR "Bad arguments.\n";
        }
        my $label = $g->{data}->{projects}->{ $g->{current} }->{label};
        $label //= '';
        print "Project: $g->{current} ($label)\n";
        print "Current files:\n";

        my %sorted;
        for ( keys %{ $g->{files} } ) {
            my ( $a, $b ) = ( $g->{files}->{$_} =~ m!(.*)/(.*)! );
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
    return;
}

sub func_x {
    my ($g)   = @_;
    my $na    = scalar @{ $g->{args} };
    my @a     = @{ $g->{args} };
    my $f1    = 0;
    my $f2    = 0;
    my $flist = '';

    my $tmp = derange( $a[0], $g->{cmds} );
    my @l = split //, ( defined($tmp) ? $tmp : '' );

    my $g_2 = defined( $l[0] ) ? $l[0] : '';
    if ( $g_2 eq '.' or $g_2 eq '-' ) { shift @l }

    for (@l) {
        if ( !$g->{cmds}->{$_} ) { ++$f1 }
    }
    $a[1] //= '';
    if ( $a[1] =~ /^-(.*)/ ) {
        $flist = $1;
    }

    if ( $na == 1 or $g->{prog} eq 'xa' or $flist ) {
        if ( $g->{prog} eq 'xa' ) { @l = keys %{ $g->{cmds} } }
        if ( $g_2 eq '-' ) {    # Delete labels
            del( \@l, $g->{cmds}, $g );
        }
        elsif ( $g_2 eq '.' ) {    # Edit commands
            my $f = '';
            my $temp;
            if ( !$f1 ) {
                for (@l) {
                    $temp = "/tmp/c.$$.$_";
                    my $ofh = IO::File->new( $temp, '>' );
                    croak if ( !defined $ofh );

                    print $ofh
                      "$g->{cmds}->{$_}->{label}: $g->{cmds}->{$_}->{cmd}\n";
                    print $ofh
"# The label precedes the colon above and my be edited freely\n";
                    print $ofh "# As long as the colon is left intact.\n";
                    print $ofh
"# Only the first line is read. Don't add more lines to this file.\n";
                    $f .= "$temp ";

                    $ofh->close;
                }

                system("$ENV{EDITOR} $f");
                for (@l) {
                    my $m;
                    $temp = "/tmp/c.$$.$_";
                    my $ifh = IO::File->new( $temp, '<' );
                    croak if ( !defined $ifh );
                    chomp( $m = <$ifh> );
                    if ( $m =~ /(.*):\s*(.*)/ ) {
                        $g->{cmds}->{$_}->{label} = $1;
                        $g->{cmds}->{$_}->{cmd}   = $2;
                    }
                    else {
                        print STDERR
                          "Bad format on file for command labeled $_\n";
                    }
                    $ifh->close;
                    unlink $temp;
                }
                pfreeze($g);

            }
            else {
                print STDERR "Bad labels in $a[0].\n";
            }
        }
        else {    # Run commands
            my $f = '';
            if ($flist) {

                my @m = split //, derange( $flist, $g->{files} );
                for (@m) {
                    if ( $g->{files}->{$_} ) {
                        $f .= "$g->{files}->{$_} ";
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
                    print "$g->{cmds}->{$_}->{cmd} $f\n";
                    if ( system("/bin/sh -c '$g->{cmds}->{$_}->{cmd} $f'") ) {
                        print STDERR
"An error occurred while running: $g->{cmds}->{$_}->{cmd}\n";
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
        if ( $g->{h_ident}->{ $a[0] } ) {    # Add command to specific label
            $g->{cmds}->{ $a[0] }->{cmd} = $a[1];
            $g->{cmds}->{ $a[0] }->{label} = $a[2] || '';
            pfreeze($g);
        }
        elsif ( $a[0] eq ',' ) {             # Add command to generic label
            for my $i ( @{ $g->{a_ident} } ) {
                if ( !exists $g->{cmds}->{$i}->{cmd} ) {
                    $g->{cmds}->{$i}->{cmd} = $a[1];
                    $g->{cmds}->{$i}->{label} = $a[2] || '';
                    last;
                }
            }
            pfreeze($g);
        }
        else {                               # Error
            print STDERR "Invalid identifier: $a[0]\n";
            print STDERR 'Use one of: ' . join( '', @{ $g->{a_ident} } ) . "\n";
        }
    }
    else {                                   # Print list of commands
        if ( $na != 0 ) {
            print STDERR "Bad arguments.\n";
        }
        print "Project: $g->{current}\n";
        print "Current commands:\n";
        for (
            sort { lc($a) cmp lc($b) || $b cmp $a } keys %{ $g->{cmds} }
          )
        {
            printf "%1s: %-20s %-15s\n", $_, $g->{cmds}->{$_}->{label},
              $g->{cmds}->{$_}->{cmd};
        }
    }
    return;
}

sub func_z {
    my ($g) = @_;
    print fix(4,<<"    EOF"), "\n";
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
    Current project: $g->{data}->{current}
    EOF
    return;
}

sub main {
    my ( $prog, @args ) = @_;

    my $g      = {};
    my @g_keys = qw(
      a_ident
      args
      cmds
      current
      data
      files
      h_ident
      infile
      legacy_infile
      prog
    );

    lock_keys( %{$g}, @g_keys );

    $g->{args}          = \@args;
    $g->{legacy_infile} = "$ENV{HOME}/.prc";
    $g->{infile}        = "$ENV{HOME}/.pdump";

    my @ident = ( 0 .. 9, 'a' .. 'z', 'A' .. 'Z' );

    my %ident;

    @ident{@ident} = (1) x @ident;

    $g->{a_ident} = \@ident;
    $g->{h_ident} = \%ident;

    ($prog) = ( $prog =~ m!.*/(.*)! );

    if ( defined $args[0] ) {
        if ( $args[0] eq '--help' or $args[0] eq '-?' or $args[0] eq '-h' ) {
            $prog = 'z';
        }
        elsif ( $prog eq 'p' ) {
            if ( $args[0] eq 'cp' or $args[0] eq 'mv' ) {
                $prog = shift @args;
            }
        }
    }
    $g->{prog} = $prog;

    if ( -e $g->{infile} ) {
        dump_read($g);
    }
    elsif ( -r $g->{legacy_infile} ) {
        $g->{data} = retrieve( $g->{legacy_infile} );
    }
    else { $g->{data} = {} }
    init($g);

    if ( $g->{prog} eq 'cp' ) {
        pcopy( $args[0], $args[1], $g );
    }

    if ( $g->{prog} eq 'mv' ) {
        my $delete_flag = 1;
        pcopy( $args[0], $args[1], $delete_flag, $g );
    }

    if ( $g->{prog} eq 'zdir' ) { zdir($g) }

    if ( $g->{prog} eq 'p' ) { func_p($g) }

    if ( $g->{prog} eq 'f' or $g->{prog} eq 'fa' ) { func_f($g) }

    if ( $g->{prog} eq 'x' or $g->{prog} eq 'xa' ) { func_x($g) }

    if ( $g->{prog} eq 'z' ) { func_z($g) }

    return 0;
}
