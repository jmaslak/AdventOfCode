#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

MAIN: {
    my $steps_str = <<>>;
    chomp($steps_str);
    my (@steps) = split //, $steps_str;
    my $trash = <<>>;

    my %nodes;
    while (my $line = <<>>) {
        chomp($line);
        my ($node, $left, $right) = ($line =~ m/^(...) = \((...), (...)\)$/);
        $nodes{$node} = { left => $left, right => $right };
    }

    my $node = "AAA";
    my $step = 0;
    while ($node ne "ZZZ") {
        $step++;
        my $direction = shift(@steps);
        push @steps, $direction;

        if ($direction eq "L") {
            $node = $nodes{$node}->{left};
        } else {
            $node = $nodes{$node}->{right};
        }
    }

    say("Steps: $step");
}


