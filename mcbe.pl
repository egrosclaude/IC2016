#!/usr/bin/perl


use strict;
use warnings;

use GD::Simple;
GD::Simple->class('GD::SVG');

my $BIT_WIDTH = 8;
my $BIT_HEIGHT = 8;
my $LBL_GAP = 3;
my $COL_WIDTH = 100;
my $ROW_HEIGHT = 10;

sub byte {
	my ($img, $x, $y) = @_;

	for(my $i=0; $i<8; $i++) {
		$img->rectangle($x,$y,$x+$BIT_WIDTH,$y+$BIT_HEIGHT);
		$x += $BIT_WIDTH;
	}
}

sub octet {
	my ($img, $x, $y, $lbl) = @_;
	my $m = $img->fontMetrics();
	my $desc = $m->{'descent'};
	print STDERR "$desc\n";
	$img->moveTo($x,$y + $BIT_HEIGHT + $desc);
	$img->string($lbl);
	$x += length($lbl) * $BIT_WIDTH + $LBL_GAP;
	$img->moveTo($x, $y);
	byte($img, $x, $y);
}


sub memory {
	my ($img, $x, $y) = @_;
	for(my $j=0; $j<4; $j++) {
		my $y2 = $y;
		for(my $i=7; $i>=0; $i--) {
			$b = sprintf("%02d", $i + 8 * $j); 
			octet($img, $x, $y2, $b);
			$y2 += $ROW_HEIGHT;
		}
		$x += $COL_WIDTH;
	}
}

my $img = GD::Simple->new(400,110);
$img->font('Lato',$BIT_HEIGHT);
octet($img, 8, 10, "PC");
octet($img, 8 + $COL_WIDTH, 10, "IR");
octet($img, 8 + 2 * $COL_WIDTH, 10, " A");
memory($img, 8, 20);
print $img->svg;
