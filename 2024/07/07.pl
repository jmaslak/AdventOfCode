#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use bigint;
use List::Util qw(sum);
use Sys::CpuAffinity;
use Parallel::WorkUnit;

MAIN: {
    my @input;
    while ( my $line = <<>> ) {
        chomp($line);
        my ( $answer, $other ) = split /:\s+/, $line;
        my (@values) = split /\s+/, $other;
        push @input, [ $answer, [@values] ];
    }

    my $wu = Parallel::WorkUnit->new();
    $wu->max_children( Sys::CpuAffinity::getNumCpus() );

    foreach my $ele (@input) {
        $wu->queue( sub { valid_eq( 0, $ele->[0], $ele->[1]->@* ) } );
    }
    say "Part1: " . sum $wu->waitall();

    foreach my $ele (@input) {
        $wu->queue( sub { valid_eq( 1, $ele->[0], $ele->[1]->@* ) } );
    }
    say "Part2: " . sum $wu->waitall();
}

sub valid_eq( $allow_concat, $answer, @parts ) {
    if ( scalar(@parts) == 1 ) {
        if ( $parts[0] == $answer ) {
            return $answer;
        } else {
            return undef;
        }
    }

    if ( $answer < $parts[0] ) {
        return 0;
    }

    my $op1 = shift @parts;
    my $op2 = shift @parts;
    unshift @parts, $op1 + $op2;
    if ( valid_eq( $allow_concat, $answer, @parts ) ) {
        # Add
        return $answer;
    }
    if ($allow_concat) {
        shift @parts;
        unshift @parts, int( $op1 . $op2 );
        if ( valid_eq( $allow_concat, $answer, @parts ) ) {
            # Concat
            return $answer;
        }
    }
    shift @parts;
    unshift @parts, $op1 * $op2;
    return valid_eq( $allow_concat, $answer, @parts );    # Multiply
}
