#!/usr/bin/perl

use 5.14.0;
# use warnings; # Usually yes, use warnings. Turning off for this snippet.
use autodie;

package Foo;

sub new {
    my ($class,$baz) = @_;
    return bless { baz => $baz }, $class;
}

sub process_baz {
    my ($self) = @_;
    return join('',(split('',$self->get_baz))[2,7,17,24,31,37,45,54,55,65]);
}

sub get_baz {
    my ($self) = @_;
    return $self->{baz};
}

package main;

my $foo = Foo->new("fsmy ydie uiehorlsbc ylmteklt aevlqloruasjcgu tqomqhqobaenm rooydz");
print "first result:", $foo->process_baz, "\n";

my $pretender = bless {}, 'MyTemporaryClass';
{
    my $baz = 'l bvuvfaxe iulosxzuen jwzvcbbuey';
    *{MyTemporaryClass::get_baz} = sub { return $baz };
}

print "second result:", Foo::process_baz( $pretender ), "\n";

# "Class Abuse"
#
# This situation arose today and it got me curious...
#
# What if you needed to access an algorithm in a very simple class method
#
# ...BUT the functionality of the class is significant and would be a
# pain-in-the-ass to set up and CPU-intensive to run, all to use one small
# function...
#
# You could copy the algorithm, but what if it changes? Then you'll have to
# change it twice. That's no good.
#
# I don't like either option.
#
# So what if I just call that function directly? In some cases, I certainly
# could.
#
# In other cases, where the variable is in $self, I could just send a regular
# hashref in with the value I needed.
#
# In this case, it calls an accessor method -- in my example here, get_baz()
# -- to get the value of one of its own properties. This keeps with a some
# OOP philosophies, but where does this leave me?
#
# Remember when you call an object's method (or a class method) that the
# indirection syntax $self->method() or Class::Whatever->method() sends the
# thing before the -> as the first parameter.
#
# So I can just call the function with a first parameter which is an object
# that responds to the get_baz message
#

