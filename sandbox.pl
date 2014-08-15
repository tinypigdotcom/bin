#!/usr/bin/perl
# purpose: get rid of this

use 5.14.0;
use autodie;

package Decoder_Ring;

sub new {
    my ( $class, $data ) = @_;
    return bless { data => $data }, $class;
}

sub decode {
    my ($self) = @_;
    return join( '',
        ( split( '', $self->get_data ) )
          [ 2, 7, 17, 24, 31, 37, 45, 54, 55, 65, 72, 77 ] );
}

sub get_data {
    my ($self) = @_;
    return $self->{data};
}

package main;

# Here's the normal object creation and method call to decode
my $normal_object =
  Decoder_Ring->new('?sSY y#ee Uiehor$cBc yL@rekLt AevLQYotUasjCGu!Z!a"');
print "normal result: ", $normal_object->decode, "\n";

# and here's the "fake" one:
# First, bless into unique class name to avoid polluting your namespace
my $pretender_object = bless {}, 'MyTemporaryClass';
my $input_data = 'l2a*lP lu*j!BfeCxssov@osol aupu Zwv+us P'
               . 'VSMvxekv vegA*crsY$L$2^ Sei!uVC$t!N?4.3';

# Next, push a method into the symbol table of the newly created class
*{MyTemporaryClass::get_data} = sub { return $input_data };

# Now our ad-hoc object will respond appropriately to the get_data call!
print "pretender result: ", Decoder_Ring::decode($pretender_object), "\n";

