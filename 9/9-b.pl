#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use List::Util qw(any);
use Data::Dump;

MAIN: {
    my @sequences;

    while (my $line = <<>>) {
        chomp($line);
        my (@parts) = split /\s+/, $line;

        # Data structure:
        # @sequences[<sequence><row><col>]
        push @sequences, [[@parts]];
    }

    # Fill in below rows
    for my $sequence (@sequences) {
        while (any { $_ != 0 } $sequence->[-1]->@*) {
            my (@seq) = $sequence->[-1]->@*;
            my $prev = shift @seq;

            my @out;
            for my $num (@seq) {
                push @out, $num - $prev;
                $prev = $num;
            }
            push $sequence->@*, [@out];
        }

        my $previous_row_first = 0;
        my $prev;
        for my $rows (reverse $sequence->@*) {
            $prev = $rows->[0] - $previous_row_first;
            $previous_row_first = $prev;
            unshift $rows->@*, $prev;
        }
    }

    my $sum = 0;
    for my $sequence (@sequences) {
        $sum += $sequence->[0][0];
    }

    say("Sum: $sum");
}


