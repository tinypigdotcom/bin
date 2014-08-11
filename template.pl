#!/usr/bin/perl
# maybe use warnings FATAL => 'all';

# TODO
# * add errout()
# * create tests which could fix dumb errors

use Modern::Perl'2014';our$VERSION='v0.1.4';package MyTemplateScript{use Carp;use Data::Dumper;use Hash::Util qw(lock_keys);our$VAR1;my$persist_file="$ENV{HOME}/.my_template_script";my$do_persist=1;my$DEBUG=0;

my @keys = qw( argv template_bar template_foo );

sub run {
    my ( $self, @argv ) = @_;
    $self->{argv} = \@argv;

    $self->errout('too many flurples');

    $self->template_process1();
    $self->{template_foo} = 5;
    $self->{template_bar} = { name => 'baz' };
    $self->freeze_me();
    return 0; # return for entire script template
}

sub template_process1 {
    my ($self) = @_;
    print "template_process1\n";
}

sub usage {
    my ($self) = @_;

    print STDERR <<EOF;
Usage: template [OPTION]... PATTERN [FILE]...
Check for BLAHBLAHBLAH in something somewhere template
Example: template -i 'hello world' menu.h

Argument subtitle 1:
  -E, --extended-regexp     PATTERN is an extended regular expression (ERE)

Argument subtitle 2:
  -s, --no-messages         suppress error messages
EOF
}

sub errout {
    my ($self,$message) = @_;
    print STDERR "ERROR: $message\n";
    $self->usage();
    die;
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

    sub thaw_me {
        return unless $do_persist;

        my ($self) = @_;

        return unless thaw($persist_file);

        ${$self} = $VAR1;

        if ( $DEBUG ) {
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
        my ( $self, $filename ) = @_;
        if ( !ref($self) ) {
            $filename = $self;
        }

        my $ifh = IO::File->new( $filename, '<' );
        return if ( !defined $ifh );

        my $contents = do { local $/; <$ifh> };
        $ifh->close;

        return eval $contents;
    }

    sub freeze {
        my ( $self, $filename, $ref ) = @_;

        my $ofh = IO::File->new( $filename, '>' );
        croak "Failed to open output file: $!" if ( !defined $ofh );

        print $ofh Dumper($ref);
        $ofh->close;
    }

}

package main;

my $app = MyTemplateScript->new();    # TEMPLATE change
exit $app->run(@ARGV);

