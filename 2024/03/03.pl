#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

MAIN: {
    my $input = "";
    while (my $line = <<>>) {
        $input .= $line;
    }

    my $part1 = 0;
    while ($input =~ /(mul\(\d{1,3},\d{1,3}\))/g) {
        my $match = $1;
        my (@op) = $match =~ /\((\d{1,3}),(\d{1,3})/;
        $part1 += $op[0] * $op[1];
    }

    say "Part 1: $part1";
    
    my $part2 = 0;
    my $do = 1;
    while ($input =~ /((?:don\'t)|do|(?:mul\(\d{1,3},\d{1,3}\)))/g) {
        my $match = $1;
        if ($match eq "do") {
            $do = 1;
        } elsif ($match eq "don't") {
            $do = 0;
        } else {
            my (@op) = $match =~ /\((\d{1,3}),(\d{1,3})/;
            $part2 += $op[0] * $op[1] * $do;
        }
    }

    say "Part 2: $part2";
}


