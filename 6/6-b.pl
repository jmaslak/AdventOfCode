#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

MAIN: {
    my $race_time;
    my $race_distance;
    while ( my $line = <<>> ) {
        chomp($line);
        my (@parts) = split /\s+/, $line;
        my $type    = shift(@parts);
        if ( $type eq 'Time:' ) {
            $race_time = join '', @parts;
        } else {
            $race_distance = join '', @parts;
        }
    }

    my $wins = 0;
    for ( my $time = 1; $time < $race_time; $time++ ) {
        my $distance = ( $race_time - $time ) * $time;
        if ( $distance > $race_distance ) {
            $wins++;
        }
    }

    say("Wins: $wins");
}

