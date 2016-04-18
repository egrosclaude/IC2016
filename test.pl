#!/usr/bin/perl

use warnings;
use strict;

use SVG;

package MyPackage;
use parent 'SVG';


sub SVG::Element::Foo {
	my ($self, $fooArg) = @_;
	return $self->rectangle(id => $fooArg, x => 10, y => 10);
}

#sub group {
#	my ($self, $barArg) = @_;
#	return SVG::Element::group($self,$barArg);
#}

sub Bar {
	my ($self, $barArg) = @_;
	my $g = $self->group(id => $barArg);
	return $g->Foo("g$barArg");
}

package main;

my $s = MyPackage->new(); 
use Data::Dumper;
print Dumper($s);

$s->Foo("someID");
$s->Bar("someOtherID");
print $s->xmlify(namespace => 'svg');

