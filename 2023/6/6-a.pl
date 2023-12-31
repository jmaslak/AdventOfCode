#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

MAIN: {
    my @times;
    my @distances;
    while ( my $line = <<>> ) {
        chomp($line);
        my (@parts) = split /\s+/, $line;
        my $type    = shift(@parts);
        if ( $type eq 'Time:' ) {
            @times = @parts;
        } else {
            @distances = @parts;
        }
    }

    my $product = 1;
    for ( my $i = 0; $i < scalar(@times); $i++ ) {
        my $wins = 0;
        for ( my $time = 1; $time < $times[$i]; $time++ ) {
            my $distance = ( $times[$i] - $time ) * $time;
            if ( $distance > $distances[$i] ) {
                $wins++;
            }
        }
        $product *= $wins;
    }

    say("Product of wins: $product");
}

