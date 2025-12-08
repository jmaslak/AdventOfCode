#!/usr/bin/env perl

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

use lib '.';

use JTM::Boilerplate 'script';
use List::Util qw(all product);

my $PAIRS = 1000;
my $MAX   = 3;

class Box {
    field $x    : param;
    field $y    : param;
    field $z    : param;
    field $data : param;

    method x() { $x }
    method y() { $y }
    method z() { $z }

    method get()    { $data }
    method set($x)  { $data = $x }
    method string() { "$x $y $z $data" }
    method out()    { say "$x $y $z $data" }

    method vals() {
        return ( $x, $y, $z );
    }

    method dist($c) { sqrt( ( $x - $c->x )**2 + ( $y - $c->y )**2 + ( $z - $c->z )**2 ) }
}

class Distvalue {
    field $box1 : param;
    field $box2 : param;
    field $dist : param;

    method box1() { $box1 }
    method box2() { $box2 }
    method dist() { $dist }
}

class Distances {
    field @data;

    method add( $box1, $box2 ) {
        push @data, Distvalue->new( box1 => $box1, box2 => $box2, dist => $box1->dist($box2));
    }

    method ordered() {
        reverse sort { $a->dist <=> $b->dist } @data;
    }
}

sub connect_boxes( $boxes, $box1, $box2 ) {
    my $old = $box1->get;
    my $new = $box2->get;
    for my $box (@$boxes) {
        if ( $box->get == $old ) {
            $box->set($new);
        }
    }
}

MAIN: {
    my @boxes;
    my $boxcount = 0;
    while ( <<>> ) {
        chomp;
        next if $_ eq "";

        my @parts = split /,/;
        push @boxes,
          Box->new( x => $parts[0], y => $parts[1], z => $parts[2], data => scalar(@boxes) );
    }

    my $distances = Distances->new();
    for my $i ( 0 .. ( $#boxes - 1 ) ) {
        for my $j ( ( $i + 1 ) .. ($#boxes) ) {
            $distances->add( $boxes[$i], $boxes[$j] );
        }
    }

    my @ordered = $distances->ordered;
    for ( 1 .. $PAIRS ) {
        my $ele = pop @ordered;
        connect_boxes( \@boxes, $ele->box1, $ele->box2 );
    }

    my %circuits;
    for my $box (@boxes) {
        $circuits{ $box->get }++;
    }
    my @circuit_count =
      reverse sort { $a->[1] <=> $b->[1] } map { [ $_, $circuits{$_} ] } keys %circuits;
    my $part1 = product map { $_->[1] } @circuit_count[ 0 .. ( $MAX - 1 ) ];

    # Part 1 done.
    # Part 2 continues:

    my @last;
    while ( !all { $_->get == $boxes[0]->get } @boxes ) {
        my $ele = pop @ordered;
        connect_boxes( \@boxes, $ele->box1, $ele->box2 );
        @last = ( $ele->box1->x, $ele->box2->x );
    }

    my $part2 = product @last;

    say "Part 1: $part1";
    say "Part 2: $part2";
}
