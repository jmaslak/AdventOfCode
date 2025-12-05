#!/usr/bin/env perl

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

use lib '.';

use JTM::Boilerplate 'script';
use List::Util   qw(any sum);
use Range::Merge qw(merge);

class range {
    field $start : param;
    field $end   : param;

    method start() { return $start }
    method end()   { return $end }

    method contains($x) { ( $x >= $start and $x <= $end ) }
    method tuple()      { [ $start, $end ] }
}

# Determine if an element is in any range
sub in_ranges( $x, @ranges ) {
    any { $_->contains($x) } @ranges;
}

MAIN: {
    # Read input
    my ( @ranges, @items );
    my $state = 0;
    for ( <<>> ) {
        chomp;

        if ( $state == 0 ) {
            if ( !/^$/ ) {
                my @parts = split /-/;
                push @ranges, range->new( start => $parts[0], end => $parts[1] );
            } else {
                $state = 1;
            }
        } else {
            push @items, int($_);
        }
    }

    # Find all items in any range
    my $part1 = scalar grep { in_ranges( $_, @ranges ) } @items;

    # Find the count of all items in the merged ranges.
    my $part2 = sum map { $_->[1] - $_->[0] + 1 } merge( [ map { $_->tuple() } @ranges ] )->@*;

    say("Part 1: $part1");
    say("Part 2: $part2");
}

