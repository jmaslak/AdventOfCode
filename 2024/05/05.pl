#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

MAIN: {
    my $state = 0;
    my @orders;
    my @pages;
    while (my $line = <<>>) {
        chomp $line;
        if ($line eq "") {
            $state++;
            next;
        }

        if ($state == 0) {
            my ($first, $second) = split /\|/, $line;
            push @orders, [$first, $second];
        } else {
            my (@ele) = split /,/, $line;
            push @pages, [@ele];
        }
    }

    my $part1 = 0;
    my $part2 = 0;

NEXT:
    for my $pagelist (@pages) {
        my %previous;
        for my $ele (@$pagelist) {
            for my $order (grep { $_->[0] == $ele } @orders) {
                if (exists($previous{$order->[1]})) {
                    my (@neworder) = sort {ordercheck($a, $b, @orders)} @$pagelist;
                    $part2 += $neworder[scalar(@neworder) / 2];
                    next NEXT;
                }
            }
            $previous{$ele} = 1;
        }
        $part1 += $pagelist->[scalar(@$pagelist) / 2];
    }
    say "Part 1: " . $part1;
    say "Part 2: " . $part2;
}

sub ordercheck($first, $second, @orders) {
    for my $order (grep { $_->[0] == $first } @orders) {
        if ($order->[1] == $second) {
            return -1;
        }
    }
    for my $order (grep { $_->[0] == $second } @orders) {
        if ($order->[1] == $first) {
            return 1;
        }
    }
    return 0;
}


