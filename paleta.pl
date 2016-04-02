#!/usr/bin/perl

use strict;
use warnings;

use SVG;

my $IMG_WIDTH = 240;
my $IMG_HEIGHT = 240;

my $BIT_WIDTH = 38;
my $BIT_HEIGHT = 38;

my $colors = { 
	'00' => 'rgb(255,255,255)',
	'01' => 'rgb(128,0,128)',
	10 => 'rgb(207,231,245)',
	11 => 'rgb(0,107,107)',
	gray => 'rgb(153,153,153)',
	white => 'rgb(255,255,255)',
	black => 'rgb(0,0,0)',
};

sub textbox {
	my ($s, $id, $x, $y, $tx, $ty, $color, $text, $ttx, $tty) = @_;

	my $group = $s->g( id => "g$id", transform =>"translate($tx,$ty)");
	my $rect  = $group->rect( 
		id=>"b$id", x=>$x, y=>$y, width=>$BIT_WIDTH, height=>$BIT_HEIGHT, 
		style=>{ stroke=>$colors->{gray}, fill=>$color });
	my $fontsize = 28;
	$group->text(
		x=>($x + $BIT_WIDTH)/2, 
		y=>($y + $BIT_HEIGHT)/2 + 3,
		id=>"t$id", type=>'span',
		'text-anchor'=>'middle',
		'alignment-baseline'=>'middle',
		style=>{
			stroke=>$colors->{'black'},
			fill=>$colors->{'black'},
			font=>'Lato',
			'font-size'=>$fontsize},
		)->cdata($text);

	# Move below
	my $an = sprintf "%d,%d; %d,%d;", $tx, $ty, $ttx, $tty;
	$group->animateTransform(
		id=>"step$id",
		class=>"fragment",
		'data-reverse'=>"rstep$id",
		attributeName=>'transform',
		type=>'translate',
		values=> "$an",
		begin=>'indefinite',
		restart=>'click',
		calcMode=>'linear',
		dur=>'0.5s', # Didn't work in Firefox!
		repeatCount=>1,
		fill=>'freeze');

	$rect->animate( attributeName=>'fill-opacity', begin=>"step$id.end", from=>1, to=>0, dur=>'2s', fill=>'freeze');
	$rect->animate( attributeName=>'stroke-opacity', begin=>"step$id.end", from=>1, to=>0, dur=>'2s', fill=>'freeze');
#---------------------------------------------------

	# Reverse mov
	$group->animateTransform( id=>"rstep$id", attributeName=>'transform', type=>'translate', begin=>'indefinite', from=>"$ttx, $tty",
		to=>"$tx, $ty", dur=>'0.01s', repeatCount=>1, fill=>'freeze');
	$rect->animate( attributeName=>'fill-opacity', begin=>"rstep$id.end", from=>0, to=>1, dur=>'1s', fill=>'freeze');
	$rect->animate( attributeName=>'stroke-opacity', begin=>"rstep$id.end", from=>0, to=>1, dur=>'1s', fill=>'freeze');

}

my @clist = (qw/
10 10 11 10 10 
10 11 11 11 11 
10 10 11 10 10
00 10 10 01 10
00 00 10 10 10/);

my $container = SVG->new(width=>$IMG_WIDTH, height=>$IMG_HEIGHT);
my $s = $container->g(id => "s");

for(my $i=0; $i<5; $i++) {
	for(my $j=0; $j<5; $j++) {
		my $seq = 5*$i + $j;
		my $id = $clist[$seq];
		textbox($s,
			$seq,
			0,0,
			$BIT_WIDTH * $j, $BIT_HEIGHT * $i,
			$colors->{$id},
			$id,
			$BIT_WIDTH * $j + 5 *$i* $BIT_WIDTH, 250 );
	}
}

print $container->xmlify(namespace => 'svg');

