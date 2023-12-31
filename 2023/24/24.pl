#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
no warnings 'recursion';    # We know it does deep recursion!
use experimental 'args_array_with_signatures';

use lib '.';

use List::Util qw(all min);
use Math::Geometry::Planar;

MAIN: {
    local $| = 1;

    my @pos;
    my @v;
    my $i = 0;
    while ( my $line = <<>> ) {
        chomp($line);
        my ( $ptxt, $vtxt ) = split " @ ", $line;
        $pos[$i] = [ split ", ", $ptxt ];
        $v[$i]   = [ split ", ", $vtxt ];
        $i++;
    }

    my $sum = 0;
    my %parallel;
    for ( $i = 0; $i < scalar(@pos); $i++ ) {
        for ( my $j = $i + 1; $j < scalar(@pos); $j++ ) {
            $sum += check( \@pos, \@v, $i, $j, 200000000000000, 400000000000000 );
        }
    }

    say "Part A Sum: $sum";
}

sub check ( $pos, $speed, $a, $b, $min, $max ) {
    my (@p1) = $pos->[$a]->@*;
    my (@p2) = $pos->[$b]->@*;
    my (@v1) = $speed->[$a]->@*;
    my (@v2) = $speed->[$b]->@*;

    my $p1 = [ $p1[0], $p1[1] ];
    my $p2 = [ $v1[0] + $p1[0], $v1[1] + $p1[1] ];
    my $p3 = [ $p2[0], $p2[1] ];
    my $p4 = [ $v2[0] + $p2[0], $v2[1] + $p2[1] ];

    my $intersection = RayIntersection( [ $p1, $p2, $p3, $p4 ] );

    if ($intersection) {
        if ( all { $intersection->[$_] >= $min and $intersection->[$_] <= $max } 0 .. 1 ) {
            return 1;
        } else {
            return 0;
        }
    }
    return 0;
}
