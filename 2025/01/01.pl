#!/usr/bin/env perl

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

MAIN: {
    my @spins;
    while ( <<>> ) {
        chomp;
        my $dir    = substr( $_, 0, 1 );
        my $clicks = substr( $_, 1 );

        if ( $dir eq 'L' ) {
            push @spins,-$clicks;
        } else {
            push @spins,+$clicks;
        }
    }

    my $dial  = 50;
    my $part1 = 0;
    my $part2 = 0;

    for my $spin (@spins) {
        my $old = $dial;

        # If we have > 100 clicks, we'll want to normalize this, but
        # also count for part 2!
        my $hundreds = int(abs($spin)/100);
        $part2 += $hundreds;

        if ($spin < 0) {
            # Left
            $spin = $spin + ($hundreds*100);
        } else {
            # Right
            $spin %= 100;
        }

        # Spin -- note this will leave dial negative for a bit.
        $dial += $spin;

        # Do we need to increment counts?
        if ( !( $dial % 100 ) ) {
            # We end on zero, so we increment.
            $part1++;
            $part2++;
        } else {
            if ( $old != 0 ) {
                # We started on zero, so going negative isn't going
                # through zero again, so we don't count it.
                if ( ( $dial < 0 ) || ( $dial > 100 ) ) {
                    $part2++;
                }
            }
        }
        $dial %= 100;
    }

    say( "Part 1: ", $part1 );
    say( "Part 2: ", $part2 );
}

