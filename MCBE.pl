#!/usr/bin/perl

use strict;
use warnings;

my $CONFIG = {};
my $IMG_WIDTH = 420;
my $IMG_HEIGHT = 160;

my $BIT_WIDTH = 10;
my $BIT_HEIGHT = 10;

my $colors = { 
	'00' => 'rgb(255,255,255)',
	'01' => 'rgb(128,0,128)',
	'10' => 'rgb(207,251,245)',
	'11' => 'rgb(0,107,107)',
	gray => 'rgb(50,50,50)',
	white => 'rgb(255,255,255)',
	black => 'rgb(0,0,0)',
};

#package mcbe;
use parent 'SVG';
sub SVG::Element::config {
	my $self = shift;
	my ($k, $v) = @_;

	$CONFIG->{$k} = $v unless (!defined($k));
	return $CONFIG;
}

sub SVG::Element::bit {
	my ($self, $id, $x, $y) = @_;

	return $self->rectangle(id=>"r$id", 
		x=>$x, y=>$y, 
		style => { stroke=>$colors->{gray}, fill=> $colors->{'white'}},
		width => $CONFIG->{bitWidth},
		height => $CONFIG->{bitHeight});
}

sub SVG::Element::byte {
	my ($self, $id, $x, $y) = @_;

	my $g = $self->group(id => "byg$id");
	for(my $i = 0; $i<8; $i++) {
		$g->bit(
			"by${id}bi${i}", 
			$x + $i * $CONFIG->{bitWidth}, 
			$y);
	}
	return $g;
}


sub SVG::Element::asXML {
	my $self = shift;
	return $self->xmlify(namespace => 'svg');
}


sub SVG::Element::labelledByte {
	my ($self, $id, $x, $y, $lbl) = @_;
        my $fontsize = 10;
	my $g = $self->group(id => "lb$id");
	my $text = $g->text(
		x => $x + $BIT_WIDTH/2,
		y => $y + $BIT_WIDTH/2,
                id=>"t$id", 
		type=>'span',
                'text-anchor'=>'middle',
                'alignment-baseline'=>'middle',
                style=>{
                        #stroke=>$colors->{'gray'},
                        fill=>$colors->{'gray'},
                        'font-family' =>'Arial',
                        'font-size'=>$fontsize},
                )->cdata($lbl);
	my $b = $g->byte($id, $x + $BIT_WIDTH * 1.3, $y);
	return $g;
}

 

	
package main;

sub registros {
	my $s = shift;
	
	$s->labelledByte("pc", 2, 10, "PC");
	$s->labelledByte("ir", 2 + 8 * $CONFIG->{bitWidth} * 1.3, 10, "IR");
	$s->labelledByte("ac", 2 + 16 * $CONFIG->{bitWidth} * 1.3, 10, "Ac");

}

sub memoria {
	my $s = shift;

	my $lbl = 0;
	my $x0 = 2;
	my $y0 = 20;
	for(my $j=0; $j<4; $j++) {
		for(my $i=0; $i<8; $i++) {
			my $x = $x0 + 8 * $j * $CONFIG->{bitWidth} * 1.3;
			my $y = $y0 + (8 - $i) * $CONFIG->{bitHeight} * 1.3;
			my $id = 8 * $j + $i;
			$s->labelledByte($id, $x, $y, $lbl);
			$lbl++;
		}
	}
}

my $s = SVG->new(width=>$IMG_WIDTH, height=>$IMG_HEIGHT);
$s->config(qw/bitWidth 10/);
$s->config(qw/bitHeight 10/);
memoria($s);
registros($s);
print $s->asXML();


#--------------------------------------------------------------------------------------------------
__END__
sub graph2stream {
	my ($s, $id, $x, $y, $tx, $ty, $color, $t, $ttx, $tty) = @_;

	my $group = $s->g( id => "g$id", transform =>"translate($tx,$ty)");
	my $rect  = $group->rect( 
		id=>"b$id", x=>$x, y=>$y, width=>$BIT_WIDTH, height=>$BIT_HEIGHT, 
		style=>{ stroke=>$colors->{gray}, fill=>$color });
	my $fontsize = 28;
	my $text = $group->text(
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
		)->cdata($t);

	# Move below
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
		dur=>'0.5s', # Didn't work in Firefox!
		repeatCount=>1,
		fill=>'freeze');

	$rect->animate( '-method'=>'attribute', attributeName=>'fill-opacity', begin=>"step$id.end", from=>1, to=>0, dur=>'2s', fill=>'freeze');
	$rect->animate( '-method'=>'attribute', attributeName=>'stroke-opacity', begin=>"step$id.end", from=>1, to=>0, dur=>'2s', fill=>'freeze');

	# 01 -> 0 1
	$text->animate( '-method'=>'attribute', attributeName=>'letter-spacing', begin=>"step$id.end", from=>1, to=>2, dur=>'2s', fill=>'freeze');
#---------------------------------------------------

	# Reverse mov
	$group->animateTransform( '-method'=>'transform', id=>"rstep$id", attributeName=>'transform', type=>'translate', begin=>'indefinite', from=>"$ttx, $tty",
		to=>"$tx, $ty", dur=>'0.01s', repeatCount=>1, fill=>'freeze');
	$rect->animate( '-method'=>'attribute', attributeName=>'fill-opacity', begin=>"rstep$id.end", from=>0, to=>1, dur=>'1s', fill=>'freeze');
	$rect->animate( '-method'=>'attribute', attributeName=>'stroke-opacity', begin=>"rstep$id.end", from=>0, to=>1, dur=>'1s', fill=>'freeze');

	$text->animate( '-method'=>'attribute', attributeName=>'letter-spacing', begin=>"rstep$id.end", from=>2, to=>1, dur=>'1s', fill=>'freeze');
}



sub stream2graph {
	my ($s, $id, $x, $y, $tx, $ty, $color, $t, $ttx, $tty) = @_;

	my $group = $s->g( id => "g$id", transform =>"translate($tx,$ty)");
	my $rect  = $group->rect( 
		id=>"b$id", x=>$x, y=>$y, width=>$BIT_WIDTH, height=>$BIT_HEIGHT, 
		style=>{ stroke=>$colors->{gray}, fill=>$color });
	my $fontsize = 28;
	my $text = $group->text(
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
		)->cdata($t);

	# Move below
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
		dur=>'0.5s', # Didn't work in Firefox!
		repeatCount=>1,
		fill=>'freeze');

#	$rect->animate( '-method'=>'attribute', attributeName=>'fill-opacity', begin=>"step$id.end", from=>1, to=>0, dur=>'2s', fill=>'freeze');
#	$rect->animate( '-method'=>'attribute', attributeName=>'stroke-opacity', begin=>"step$id.end", from=>1, to=>0, dur=>'2s', fill=>'freeze');

	# 01 -> 0 1
	$text->animate( '-method'=>'attribute', attributeName=>'letter-spacing', begin=>"step$id.end", from=>1, to=>2, dur=>'2s', fill=>'freeze');
#---------------------------------------------------
	# Reverse mov
	$group->animateTransform( '-method'=>'transform', id=>"rstep$id", attributeName=>'transform', type=>'translate', 
				begin=>'indefinite', from=>"$ttx, $tty", to=>"$tx, $ty", dur=>'0.01s', repeatCount=>1, fill=>'freeze');
#	$rect->animate( '-method'=>'attribute', attributeName=>'fill-opacity', begin=>"rstep$id.end", from=>0, to=>1, dur=>'1s', fill=>'freeze');
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

sub grafo1 {
	for(my $i=0; $i<5; $i++) {
		for(my $j=0; $j<5; $j++) {
			my $seq = 5*$i + $j;
			my $id = $clist[$seq];
			graph2stream($s,
				$seq,
				0,0,
				$BIT_WIDTH * $j, $BIT_HEIGHT * $i,
				$colors->{$id},
				$id,
				$BIT_WIDTH * $j + 5 *$i* $BIT_WIDTH, 250 );
		}
	}
}

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
				(800 - 3 * $BIT_WIDTH) + $BIT_WIDTH * ($j % 3), $BIT_HEIGHT * $i,
			);
		}
	}
}

grafo1();
print $container->xmlify(namespace => 'svg');

