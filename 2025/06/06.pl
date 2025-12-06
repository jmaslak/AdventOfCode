#!/usr/bin/env perl

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

use lib '.';

use JTM::Boilerplate 'script';
use List::Util qw(all reduce);

MAIN: {
    my @lines;
    while ( <<>> ) {
        chomp;
        next if /^$/;
        push @lines, $_;
    }

    say( "Part 1: ", part1(@lines) );
    say( "Part 2: ", part2(@lines) );
}

sub part1(@lines) {
    my @t;

    for my $line (@lines) {
        $line =~ s/^\s+//;
        push @t, [ split /\s+/, $line ];
    }

    my @ops    = pop(@t)->@*;
    my $maxcol = $#ops;

    my $ret = 0;

    for my $col ( 0 .. $maxcol ) {
        my $op = shift @ops;
        if ( $op eq '*' ) {
            $ret += reduce { $a * $b } map { $t[$_]->[$col] } 0 .. $#t;
        } elsif ( $op eq '+' ) {
            $ret += reduce { $a + $b } map { $t[$_]->[$col] } 0 .. $#t;
        }
    }

    return $ret;
}

sub part2(@lines) {
    my @ops    = split /\s+/, pop(@lines);
    my @array  = map { [ split( //, $_ ) ] } @lines;
    my $maxcol = scalar( $array[0]->@* ) - 1;
    my $maxrow = $#array;

    my @t = ( [] );
    for my $col ( reverse 0 .. $maxcol ) {
        my $num = join "", grep { /[^\s]/ } map { $array[$_]->[$col] } 0 .. $maxrow;
        if ( $num eq "" ) {
            push @t, [];
        } else {
            push $t[-1]->@*, $num;
        }
    }

    my $ret = 0;

    for my $nums (@t) {
        my $op = pop(@ops);
        if ( $op eq '*' ) {
            $ret += reduce { $a * $b } @$nums;
        } elsif ( $op eq '+' ) {
            $ret += reduce { $a + $b } @$nums;
        }
    }

    return $ret;
}

