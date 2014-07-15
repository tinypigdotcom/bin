#!/usr/bin/perl

use 5.14.0;
use autodie;
use warnings FATAL => 'all';

use IO::File;

package Aaa01
{

    use Carp;
    use Data::Dumper;
    use Hash::Util qw(lock_keys);
    our $VAR1;

    my $persist_file = "$ENV{HOME}/.aaa01";
    my $do_persist = 0;

    my @keys = qw(
      argv
      bar
      foo
      bar
    );

    sub new {
        my ($class) = @_;

        my $self = { };
        bless $self, $class;
        thaw(\$self);
        lock_keys( %$self, @keys );

        return $self;
    }

    sub run {
        my ($self,@argv) = @_;
        $self->{argv} = \@argv;

        $self->message();
        $self->{foo} = 3;
        $self->{bar} = {name=>'baz'};
        $self->freeze();
        return 0; # return for entire script
    }

    sub message {
        my ($self) = @_;
        print "howdy\n";
    }

    sub thaw {
        return unless $do_persist;

        my ($self) = @_;

        my $ifh = IO::File->new($persist_file, '<');
        return if (!defined $ifh);

        my $contents = do { local $/; <$ifh> };
        $ifh->close;

        ${$self} = eval $contents;
        if ( !defined $self ) {
            croak "failed eval of dump";
        }
    }

    sub freeze {
        return unless $do_persist;

        my ($self) = @_;

        my $ofh = IO::File->new($persist_file, '>');
        croak "Failed to open output file: $!" if (!defined $ofh);

        print $ofh Dumper($self);
        $ofh->close;
    }

}

package main;

my $app = Aaa01->new();
exit $app->run(@ARGV);

