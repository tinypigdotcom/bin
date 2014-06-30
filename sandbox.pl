#!/usr/bin/perl

use 5.14.0;
use warnings;
use autodie;

package Foo;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub do_stuff {
    my ($self) = @_;
    print "My baz is {", $self->get_baz, "}\n";
}

sub get_baz {
    return "Mr. Baz";
}

package main;

my $foo = Foo->new();
$foo->do_stuff;

my $pretender = bless{}, 'MyTemporaryClass';

{
    no warnings 'once';
    my $bazval = 'Bazzy!';
    *{MyTemporaryClass::get_baz} = sub { return $bazval };
}
Foo::do_stuff( $pretender );

