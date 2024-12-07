#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use bigint;
use List::Util qw(sum);

MAIN: {
    my @input;
    while (my $line = <<>>) {
        chomp($line);
        my ($answer, $other) = split /:\s+/, $line;
        my (@values) = split /\s+/, $other;
        push @input, [$answer, [@values]];
    }

    my $part1 = sum map {$_->[0]} grep {valid_eq(undef, $_->[0], $_->[1]->@*)} @input;
    say "Part1: $part1";

    my $part2 = sum map {$_->[0]} grep {valid_eq(1, $_->[0], $_->[1]->@*)} @input;
    say "Part2: $part2";
}

sub valid_eq($allow_concat, $answer, @parts) {
    if (scalar(@parts) == 1) {
        if ($parts[0] == $answer) {
            return 1;
        } else {
            return undef;
        }
    }

    if ($answer < $parts[0]) {
        return undef;
    }

    my $op1 = shift @parts;
    my $op2 = shift @parts;
    unshift @parts, $op1 + $op2;
    if (valid_eq($allow_concat, $answer, @parts)) {
        # Add
        return 1;
    }
    if ($allow_concat) {
        shift @parts;
        unshift @parts, int($op1 . $op2);
        if (valid_eq($allow_concat, $answer, @parts)) {
            # Concat
            return 1;
        }
    }
    shift @parts;
    unshift @parts, $op1 * $op2;
    return valid_eq($allow_concat, $answer, @parts);  # Multiply
}
