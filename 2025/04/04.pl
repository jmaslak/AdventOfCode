#!/usr/bin/env perl

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

use lib '.';

use JTM::Boilerplate 'script';
use Table;

MAIN: {
    my $t = Table->new();
    $t->read( \*STDIN );

    my $part1;
    my $part2 = 0;

    while (1) {
        my @coords = grep { movable( $t, $_ ) } $t->find('@');
        $part1 //= scalar(@coords);
        $part2 += scalar(@coords);
        $t->put( $_, 'x' ) for @coords;
        last unless @coords;
    }

    say("Part 1: $part1");
    say("Part 2: $part2");
}

sub movable( $t, $c ) {
    return scalar(
        grep { /@/ }
        map  { $t->get($_) } $t->neighbors8($c)
    ) < 4;
}
