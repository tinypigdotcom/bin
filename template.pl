#!/usr/bin/perl
# purpose: template for creating new scripts
# maybe use warnings FATAL => 'all';

# TODO
# * create tests which could fix dumb errors

use Modern::Perl '2014';use warnings;our$TEMPLATE_VERSION='v0.1.12';package MyTemplateScript{use Carp;use Data::Dumper;use Hash::Util qw(lock_keys);our$VAR1;my$persist_file="$ENV{HOME}/.my_template_script";my$do_persist=0;my$DEBUG=0;

our $VERSION = 'v0.0.0'; #template
my @keys = qw( argv switches template_switch1 template_switch2 input_file );

sub run {
    my ( $self, @argv ) = @_;
    $self->{argv} = \@argv;

    $self->check_inputs();

    $self->main_template_run();
    $self->freeze_me();
    return 0;    # return for entire script template
}

sub main_template_run {
    my ($self) = @_;

    my $input_file=$self->{input_file}||$0;
    my $ifh = IO::File->new( $input_file, '<' );
    die "can't open $input_file: $!" if ( !defined $ifh );

    while (<$ifh>) {
        chomp;
        print "*** l: $_\n";
    }
    $ifh->close;
}

sub usage {
    croak "This is a function, not a method" if ( ref $_[0] );

    return <<EOF;
Usage: template [OPTION]... PATTERN [FILE]...
Check for BLAHBLAHBLAH in something somewhere template
Example: template -i 'hello world' menu.h

Argument subtitle 1:
-E, --extended-regexp     PATTERN is an extended regular expression (ERE)

Argument subtitle 2:
-s, --no-messages         suppress error messages
EOF
}

sub check_inputs {
    my ( $self ) = @_;
    my %valid_switch = (
        '-a' => 'template_switch1',
        '-b' => 'template_switch2',
    );
    while ( my $arg = shift( @{ $self->{argv} } ) ) {
        if ( $arg =~ /^(-.*)/ ) {
            my $switch = $1;
            if ( $switch eq '-?' or $switch eq '-h' or $switch eq '--help' )
            {
                print STDERR usage();
                exit 2;
            }
            if ( !$valid_switch{$switch} ) {
                errout("bad switch $switch");
            }
            $self->{ $valid_switch{$switch} }++;
        }
        else {    # template start non-switch args
            if ( @{ $self->{argv} } > 0 )
            {     # template how many input files allowed
                errout(
                    message  => "too many input files",
                    no_usage => 1
                );
            }
            if ( !-r $arg ) {
                errout(
                    message  => "can't read file \"$arg\"",
                    no_usage => 1
                );
            }
            $self->{input_file} = $arg;
            last;
        }
    }
    # template remove "0 &&" to turn on
    if ( 0 && !$self->{input_file} ) {
        errout(
            message  => "no valid input files provided",
            no_usage => 1
        );
    }
    # template remove "0 &&" to turn on
    if ( 0 && ( !$self->{template_switch1} and !$self->{template_switch2} )
           or ( $self->{template_switch1} and $self->{template_switch2} ) )
    {
        errout("must use either -a or -b");
    }
}

 # ================== END MAIN =================================================

    sub new {
        my ($class) = @_;

        my $self = {};
        bless $self, $class;
        thaw_me( \$self );
        lock_keys( %$self, @keys );

        return $self;
    }

    sub errout {
        croak "This is a function, not a method" if ( ref $_[0] );

        my %params;
        if ( @_ == 1 ) {
            $params{message} = $_[0];
        }
        else {
            %params = @_;
        }
        my $message = "error: $params{message}\n";
        if ( !$params{no_usage} ) {
            $message .= usage();
        }
        die $message;
    }

    sub thaw_me {
        return unless $do_persist;

        my ($self) = @_;

        return unless thaw($persist_file);

        ${$self} = $VAR1;

        if ($DEBUG) {
            warn "thawed!\n", Dumper($self);
        }
        if ( !defined $self ) {
            croak "failed eval of dump";
        }
    }

    sub freeze_me {
        return unless $do_persist;

        my ($self) = @_;
        $self->freeze( $persist_file, $self );
    }

    sub thaw {
        croak "This is a function, not a method" if ( ref $_[0] );

        my ($filename) = @_;

        my $ifh = IO::File->new( $filename, '<' );
        return if ( !defined $ifh );

        my $contents = do { local $/; <$ifh> };
        $ifh->close;

        return eval $contents;
    }

    sub freeze {
        croak "This is a function, not a method" if ( ref $_[0] );

        my ( $filename, $ref ) = @_;

        my $ofh = IO::File->new( $filename, '>' );
        croak "Failed to open output file: $!" if ( !defined $ofh );

        print $ofh Dumper($ref);
        $ofh->close;
    }

    sub random {
        croak "This is a function, not a method" if ( ref $_[0] );

        my ( $max, $min ) = @_;

        $min //= 1;
        if ( $min > $max ) {
            ( $min, $max ) = ( $max, $min );
        }
        my $range = $max - $min;
        return int( rand( $range + 1 ) ) + $min;
    }

    # example
    # my @dot_files = grep { /^\./ && -f "$some_dir/$_" } get_directory($target);
    sub get_directory {
        croak "This is a function, not a method" if ( ref $_[0] );

        my ($dir) = @_;
        $dir ||= '.';

        opendir(my $dh, $dir) || die "can't opendir $dir: $!";
        my @files = readdir($dh);
        closedir $dh;

        return @files;
    }
}

package main;

my $app = MyTemplateScript->new();
exit $app->run(@ARGV);

