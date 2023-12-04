#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use List::Util qw/any sum/;

MAIN: {
    my $sum   = 0;
    my $cards = 0;
    my @cardcounts;
    $cardcounts[0] = 0;
    while ( my $line = <<>> ) {
        $cards++;
        chomp($line);
        my ( $card, $winning, $mine ) = $line =~ m/^Card\s+(\d+):\s+([\d\s]+)\s\|\s+(.*)$/;
        @cardcounts[$card]++;
        my (@wins)  = split / +/, $winning;
        my (@mines) = split / +/, $mine;

        my $winning_numbers = 0;
        for my $num (@mines) {
            if ( any { $num == $_ } @wins ) {
                $winning_numbers++;
            }
        }
        if ($winning_numbers) {
            for my $num ( ( $card + 1 ) .. ( $card + $winning_numbers ) ) {
                $cardcounts[$num] += $cardcounts[$card];
            }
        }
    }

    say( "Cards: " . sum(@cardcounts) );
}

