#!/usr/bin/env raku
use v6.d;

#
# Copyright © 2023 Joelle Maslak
# All Rights Reserved - See License
#

sub MAIN() {
    my @sequences;
    for $*IN.lines() -> $line {
        my @matches = $line.words;
        @sequences.push: [];  # Add a new sequence
        @sequences.tail.push: @matches.map(*.Int).List;  # Add a new row
    }

    # Fill in the rows
    for @sequences -> @sequence {  # Get a sequence
        while @sequence.tail.first(* ≠ 0) {
            my (@seq) = @sequence.tail;
            my ($prev) = @seq.shift;
            
            my @out;
            for @seq -> $num {
                @out.push: $num - $prev;
                $prev = $num;
            }
            @sequence.push: @out;
        }

        my $prevFirst = 0;
        my $prevLast = 0;
        for (0..^(@sequence.elems - 1)).reverse -> $index {
            my (@row) = @sequence[$index];
            $prevFirst = @row.head - $prevFirst;
            $prevLast = @row.tail + $prevLast;

            @row.unshift: $prevFirst;
            @row.push: $prevLast;

            @sequence[$index] = @row;
        }
    }

    my $sumLast := [+] @sequences.map: *.head.tail;
    my $sumFirst := [+] @sequences.map: *.head.head;
    say("Sum last (Part A): $sumLast");
    say("Sum prev (Part B): $sumFirst");
}


