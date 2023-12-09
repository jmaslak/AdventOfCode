#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use List::Util qw(any);

MAIN: {
    my @sequences;

    while ( my $line = <<>> ) {
        chomp($line);
        my (@parts) = split /\s+/, $line;

        # Data structure:
        # @sequences[<sequence><row><col>]
        push @sequences, [ [@parts] ];
    }

    # Fill in below rows
    for my $sequence (@sequences) {
        while ( any { $_ != 0 } $sequence->[-1]->@* ) {
            my (@seq) = $sequence->[-1]->@*;
            my $prev = shift @seq;

            my @out;
            for my $num (@seq) {
                push @out, $num - $prev;
                $prev = $num;
            }
            push $sequence->@*, [@out];
        }

        my $previous_row_last = 0;
        my $next;
        for my $rows ( $sequence->@* ) {
            $next              = $previous_row_last + $rows->[-1];
            $previous_row_last = $next;
        }
        push $sequence->[0]->@*, $next;
    }

    my $sum = 0;
    for my $sequence (@sequences) {
        $sum += $sequence->[0][-1];
    }

    say("Sum: $sum");
}

