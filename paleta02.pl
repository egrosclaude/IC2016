#!/usr/bin/perl

use strict;
use warnings;

use SVG;

my $IMG_WIDTH = 240;
my $IMG_HEIGHT = 80;

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


sub stream2graph {
	my ($s, $id, $x, $y, $tx, $ty, $color, $t, $ttx, $tty) = @_;

	my $group = $s->g( id => "g$id", transform =>"translate($tx,$ty)");
	#my $rect = $group->rect( id=>"b$id", x=>$x, y=>$y, width=>$BIT_WIDTH, height=>$BIT_HEIGHT, style=>{ stroke=>$colors->{gray}, fill=>$color });
	my $fontsize = 28;
	my $text = $group->text(
		x=>($x + $BIT_WIDTH)/2, 
		y=>($y + $BIT_HEIGHT)/2 + 3,
		id=>"t$id", type=>'span',
		'text-anchor'=>'middle',
		'alignment-baseline'=>'middle',
		'letter-spacing'=>2,
		style=>{
			stroke=>$colors->{'black'},
			fill=>$colors->{'black'},
			font=>'Lato',
			'font-size'=>$fontsize},
		)->cdata($t);

	if($id >= 18) { return; }

	# Move 
	my $an = sprintf "%d,%d; %d,%d;", $tx, $ty, $ttx, $tty;
	$group->animateTransform(
		'-method'=>'transform',
		id=>"step$id",
		class=>"fragment",
		'data-reverse'=>"rstep$id",
		attributeName=>'transform',
		type=>'translate',
		values=> "$an",
		begin=>'indefinite',
		restart=>'click',
		calcMode=>'linear',
		dur=>'0.5s', # .5 Didn't work in Firefox!
		repeatCount=>1,
		fill=>'freeze');
				
	#(800 - 3 * $BIT_WIDTH) + $BIT_WIDTH * ($id % 3), $BIT_HEIGHT * int($id / 3),
	my $r = $s->rect( 
			id=>"nb$id", 
			#x=>( $IMG_WIDTH - 100 + $id % 3) * $BIT_WIDTH,
			x=>(800-3*$BIT_WIDTH)  + 1.5 * ($id % 2) * $BIT_WIDTH,
			#y=>$tty + $BIT_HEIGHT * int($id/3), 
			y=>$tty,
			width=>1.5 * $BIT_WIDTH, 
			height=>$BIT_HEIGHT, 
			style=>{ stroke=>$colors->{gray}, fill=>$color, 'fill-opacity'=>0, 'stroke-opacity'=>1});



	#my $rect = $group->rect( id=>"b$id", x=>$x, y=>$y, width=>$BIT_WIDTH, height=>$BIT_HEIGHT, style=>{ stroke=>$colors->{gray}, fill=>$color });

#	$rect->animate( '-method'=>'attribute', attributeName=>'fill-opacity', begin=>"step$id.end", from=>1, to=>0, dur=>'2s', fill=>'freeze');
#	$rect->animate( '-method'=>'attribute', attributeName=>'stroke-opacity', begin=>"step$id.end", from=>1, to=>0, dur=>'2s', fill=>'freeze');

	# 01 -> 0 1
	#$text->animate( '-method'=>'attribute', attributeName=>'letter-spacing', begin=>"step$id.end", from=>1, to=>2, dur=>'2s', fill=>'freeze');
#---------------------------------------------------
	# Reverse mov
	$group->animateTransform( '-method'=>'transform', id=>"rstep$id", attributeName=>'transform', type=>'translate', 
				begin=>'indefinite', from=>"$ttx, $tty", to=>"$tx, $ty", dur=>'0.01s', repeatCount=>1, fill=>'freeze');
#	$r->animate( '-method'=>'attribute', attributeName=>'fill-opacity', begin=>"rstep$id.end", from=>0, to=>1, dur=>'1s', fill=>'freeze');
#	$rect->animate( '-method'=>'attribute', attributeName=>'stroke-opacity', begin=>"rstep$id.end", from=>0, to=>1, dur=>'1s', fill=>'freeze');
#	$text->animate( '-method'=>'attribute', attributeName=>'letter-spacing', begin=>"rstep$id.end", from=>2, to=>1, dur=>'1s', fill=>'freeze');
}

my @clist = (qw/
10 10 11 10 10 
10 11 11 11 11 
10 10 11 10 10
00 10 10 01 10
00 00 10 10 10/);

my $container = SVG->new(width=>$IMG_WIDTH, height=>$IMG_HEIGHT);
my $s = $container->g(id => "s");


# my ($s, $id, $x, $y, $tx, $ty, $color, $t, $ttx, $tty) = @_;
sub grafo2 {
	for(my $i=0; $i<5; $i++) {
		for(my $j=0; $j<5; $j++) {
			my $id = 5 * $i + $j;
			my $label = $clist[$id];
			stream2graph($s,
				$id,
				0,0,
				$BIT_WIDTH * $j + 5 *$i* $BIT_WIDTH, 250,
				$colors->{$label},
				$label,
				(800 - 3 * $BIT_WIDTH) + $BIT_WIDTH * ($id % 3), $BIT_HEIGHT * int($id / 3),
			);
		}
	}
}

grafo2();
print $container->xmlify(namespace => 'svg');

