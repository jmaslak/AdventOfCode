#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

MAIN: {
    my (@a, @b);
    my (@left, %right);
    while (my $line = <<>>) {
        chomp($line);
        my @parts = split /\s+/, $line;
        push @a, $parts[0];
        push @b, $parts[1];
        push @left, $parts[0];
        $right{$parts[1]}++;
    }

    @a = sort {$a <=> $b} @a;
    @b = sort {$a <=> $b} @b;

    my $sum = 0;
    my $simularity ;
    while (scalar(@a)) {
        my $i = pop @a;
        my $j = pop @b;
        $sum += abs($i - $j);
    }

    say "Part 1: $sum";

    $sum = 0;
    for my $i (@left) {
        $sum += ($right{$i} // 0) * $i;
    }

    say "Part 2: $sum";
}


