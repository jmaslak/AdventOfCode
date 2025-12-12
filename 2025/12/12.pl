#!/usr/bin/env perl

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

use lib '.';

use JTM::Boilerplate 'script';
use Table;
use List::Util qw(sum zip);

# All shapes are 3x3

class Box {
    field $x : param;
    field $y : param;
    field $items : param;

    method x()     { $x }
    method y()     { $y }
    method items() { @$items }

    method units()  { $x * $y }
    method units3() { int( $x / 3 ) * int( $y / 3 ) }
}

sub easyfit( $box, $shapes ) {
    return ( $box->units3 >= sum $box->items() );
}

sub impossible( $box, $shapes ) {
    my $used = sum map { $_->[0] * $_->[1]->used("#") } zip [ $box->items ], $shapes;
    return ( $used > $box->units );
}

MAIN: {
    my @boxes;
    my @shapes;

    my $z = 0;
    while ( <<>> ) {
        chomp;
        next if /^$/;

        if (/^\d+:/) {
            my $t = Table->new();
            $t->read(*STDIN);
            push @shapes, $t;
        } else {
            my ( $x, $y, $i ) = /^(\d+)x(\d+): (.*)$/;
            push @boxes, Box->new( x => $x, y => $y, items => [ split / /, $i ] );
        }
    }

    my $easyfit    = 0;
    my $impossible = 0;
    for my $box (@boxes) {
        if ( easyfit( $box, \@shapes ) ) {
            $easyfit++;
            next;
        }

        if ( impossible( $box, \@shapes ) ) {
            $impossible++;
            next;
        }
    }

    if ( $easyfit + $impossible != scalar(@boxes) ) { die("You need to write more code.") }
    say "Part 1: $easyfit";
}
