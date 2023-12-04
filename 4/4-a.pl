#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use List::Util qw/any/;

MAIN: {
    my $sum = 0;
    while ( my $line = <<>> ) {
        chomp($line);
        say $line;
        my ( $winning, $mine ) = $line =~ m/^Card\s+\d+:\s+([\d\s]+)\s\|\s+(.*)$/;
        my (@wins)  = split / +/, $winning;
        my (@mines) = split / +/, $mine;

        my $power = -1;
        for my $num (@mines) {
            if ( any { $num == $_ } @wins ) {
                $power++;
            }
        }
        if ( $power >= 0 ) {
            $sum += 2**$power;
        }
    }

    say( "Winning points: " . $sum );
}

