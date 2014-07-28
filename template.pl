#!/usr/bin/perl

use Modern::Perl '2014';
our $VERSION = 'v0.1.2';

# use warnings FATAL => 'all'; #template?

package MyTemplateScript {

    use Carp;
    use Data::Dumper;
    use Hash::Util qw(lock_keys);
    our $VAR1;

    my $persist_file = "$ENV{HOME}/.my_template_script";
    my $do_persist   = 1;

    my @keys = qw( argv template_bar template_foo );

    # ------------------ "MAIN" ------------------------
    sub run {
        my ( $self, @argv ) = @_;
        $self->{argv} = \@argv;

        $self->template_process1();
        $self->template_process2();
        $self->{template_foo} = 3;
        $self->{template_bar} = { name => 'baz' };
        $self->freeze();
        return 0;    # return for entire script template
    }

    sub template_process1 {
        my ($self) = @_;
        print "template_howdy\n";
    }

    sub template_process2 {
        my ($self) = @_;
        print "template_hey\n";
    }

    sub new {
        my ($class) = @_;

        my $self = {};
        bless $self, $class;
        thaw( \$self );
        lock_keys( %$self, @keys );

        return $self;
    }

    sub thaw {
        return unless $do_persist;

        my ($self) = @_;

        my $ifh = IO::File->new( $persist_file, '<' );
        return if ( !defined $ifh );

        my $contents = do { local $/; <$ifh> };
        $ifh->close;

        ${$self} = eval $contents;
        warn "Thawed! (template)\n", Dumper($self);
        if ( !defined $self ) {
            croak "failed eval of dump";
        }
    }

    sub freeze {
        return unless $do_persist;

        my ($self) = @_;

        my $ofh = IO::File->new( $persist_file, '>' );
        croak "Failed to open output file: $!" if ( !defined $ofh );

        print $ofh Dumper($self);
        $ofh->close;
    }

}

package main;

my $app = MyTemplateScript->new();    # TEMPLATE change
exit $app->run(@ARGV);

