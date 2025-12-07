#!/usr/bin/env perl

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

use lib '.';

use JTM::Boilerplate 'script';
no warnings 'recursion';

use Memoize;
use Table;

memoize('draw_beam');

# This both draws the beam in the table AND counts the number of
# timelines (I.E. part 2).  Memoized to finish before heat death of
# universe.
sub draw_beam( $t, $row, $col ) {
    my $c = Coord->new( row => $row, col => $col );
    if ( !$t->is_in_bounds($c) ) { return 0 }

    if ( $t->get($c) eq 'S' ) {    # Starting position
        return 1 + draw_beam( $t, $c->s->rowcol );
    } elsif ( $t->get($c) eq '^' ) {    # Beam split (I add 1 for the split)
        return 1 + draw_beam( $t, $c->w->rowcol() ) + draw_beam( $t, $c->e->rowcol );
    } else {
        $t->put( $c, '|' );             # No split
        return draw_beam( $t, $c->s->rowcol );
    }
    die("Can't reach this code.");
}

sub part2($t) {
    return 1;
}

MAIN: {
    my $t = Table->new();
    $t->read( \*STDIN );

    # Side effect updates the table with beam positions
    my $part2 = draw_beam( $t, $t->find_first("S")->rowcol );

    # In the drawn table, I look for the number of ^ with a 'S', '^',
    # or '|' above it to solve part 1 (the number of beam splits).
    my $part1 = 0;
    for my $c ( $t->find('^') ) {
        if ( index( "^|S", $t->get( $c->n ) ) >= 0 ) {
            $part1++;
        }
    }

    say "Part 1: $part1";
    say "Part 2: $part2";
}

