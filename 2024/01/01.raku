#!/usr/bin/env raku
use v6.d;

#
# Copyright © 2024 Joelle Maslak
# All Rights Reserved - See License
#

sub MAIN() {
    # Just reading the input here.
    my Int:D (@left, @right);
    for $*IN.lines -> $line {
        my Int:D ($l, $r) = $line.split(/\s+/)».Int;
        @left.push($l);
        @right.push($r);
    }

    # Doing part 1 was easy:
    say "Part 1: " ~ (@left.sort Z- @right.sort)».abs.sum;

    # Part 2 needs the part 1 stuff put in a bag:
    my $rightbag = bag @right;
    say "Part 2: " ~ @left.map( { $rightbag{$^l} * $^l } ).sum;
}


