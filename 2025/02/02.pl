#!/usr/bin/env perl

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

class range {
    field $start : param;
    field $end : param;

    method start() { return $start }
    method end() { return $end }
}

MAIN: {
    my $line = "";
    while (<<>>) {
        chomp;
        $line .= $_;
    }

    my @ranges;
    for my $ele (split /,/, $line) {
        my ($s, $e) = split /-/, $ele;
        push @ranges, range->new(start => $s, end => $e);
    }

    my $part1 = 0;
    my $part2 = 0;
    for my $range (@ranges) {
        $part1 += dupes($range);
        $part2 += dupes2($range);
    }
    say("Part 1: $part1");
    say("Part 2: $part2");
}

# Solutions for part 1
sub dupes($range) {
    my $sum = 0;
    for (my $i=$range->start; $i<$range->end; $i++) {
        if ($i =~ m/^(.*)\1$/) {
            $sum += $i;
        }
    }
    return $sum;
}

# Solutions for part 2
sub dupes2($range) {
    my $sum = 0;
    for (my $i=$range->start; $i<$range->end; $i++) {
        if ($i =~ m/^(.+)\1+$/) {
            $sum += $i;
            next;
        }
    }
    return $sum;
}


