#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
no warnings 'recursion';    # We know it does deep recursion!
use experimental 'args_array_with_signatures';

use lib '.';
use Table;

use List::Util qw(min sum);
use Data::Dump;
use Memoize;

MAIN: {
    memoize('get_costs');
    my $t = Table->new();
    $t->read( *ARGV, sub { split // } );

    # Part A

    my $dist = Table->new();
    get_dist( $t, $dist, 1, 4 );

    my $start = Coord->new( row => 0, col => 0 );
    my $cost  = Table->new();
    get_costs( $dist, $cost, $start, 'H', 0 );
    get_costs( $dist, $cost, $start, 'V', 0 );

    my $min = min values $cost->get_xy( $cost->row_count() - 1, $cost->col_count() - 1 )->%*;
    say "Heat loss part A: $min";

    # Part B

    $dist = Table->new();
    get_dist( $t, $dist, 4, 10 );

    $start = Coord->new( row => 0, col => 0 );
    $cost  = Table->new();
    get_costs( $dist, $cost, $start, 'H', 0 );
    get_costs( $dist, $cost, $start, 'V', 0 );

    $min = min values $cost->get_xy( $cost->row_count() - 1, $cost->col_count() - 1 )->%*;
    say "Heat loss part B: $min";
}

sub get_dist ( $t, $dist, $mindist, $maxdist ) {
    my $maxi = $t->row_count();
    my $maxj = $t->col_count();

    my @c;
    for ( my $i = 0; $i < $maxi; $i++ ) {
        $c[$i] = [];
        for ( my $j = 0; $j < $maxj; $j++ ) {
            $c[$i]->[$j] = $t->get_xy( $i, $j );
        }
    }
    for ( my $i = 0; $i < $maxi; $i++ ) {
        for ( my $j = 0; $j < $maxj; $j++ ) {
            my %edges = (
                h => [],
                v => [],
            );
            my $running_up = 0;
            my $running_dn = 0;
            for ( my $di = 1; $di <= $maxdist; $di++ ) {
                if ( $i + $di < $maxi ) {
                    $running_up += $c[ $i + $di ]->[$j];
                    if ( $di >= $mindist ) { push $edges{v}->@*, [ $i + $di, $j, $running_up ] }
                }
                if ( $i - $di >= 0 ) {
                    $running_dn += $c[ $i - $di ]->[$j];
                    if ( $di >= $mindist ) { push $edges{v}->@*, [ $i - $di, $j, $running_dn ] }
                }
            }
            $running_up = 0;
            $running_dn = 0;
            for ( my $dj = 1; $dj <= $maxdist; $dj++ ) {
                if ( $j + $dj < $maxj ) {
                    $running_up += $c[$i]->[ $j + $dj ];
                    if ( $dj >= $mindist ) { push $edges{h}->@*, [ $i, $j + $dj, $running_up ]; }
                }
                if ( $j - $dj >= 0 ) {
                    $running_dn += $c[$i]->[ $j - $dj ];
                    if ( $dj >= $mindist ) { push $edges{h}->@*, [ $i, $j - $dj, $running_dn ]; }
                }
            }
            $dist->put_xy( $i, $j, \%edges );
        }
    }
    return;
}

sub get_costs ( $t, $cost, $start, $dir, $init_cost ) {
    # Cost structure is:
    # { R1 => cost, R2 => cost }
    $cost->put( $start, undef );
    my @stack;
    push @stack, [ $start->row(), $start->col(), $dir, $init_cost ];

    while ( my $top = shift @stack ) {
        my ( $start_x, $start_y, $dir, $costval ) = @$top;
        my $me = $cost->get_xy( $start_x, $start_y );
        if ( !defined($me) ) {
            $cost->put_xy( $start_x, $start_y, {} );
        }
        if ( ( !exists( $me->{$dir} ) ) or $costval < $me->{$dir} ) {
            $me->{$dir} = $costval;
        } else {
            next;
        }

        my @nodes;
        my $newdir;
        if ( $dir eq 'V' ) {
            @nodes  = $t->get_xy( $start_x, $start_y )->{h}->@*;
            $newdir = 'H';
        }
        if ( $dir eq 'H' ) {
            @nodes  = $t->get_xy( $start_x, $start_y )->{v}->@*;
            $newdir = 'V';
        }

        for my $node (@nodes) {
            my ( $i, $j, $edgecost ) = @$node;
            push @stack, [ $i, $j, $newdir, $edgecost + $costval ];
        }
    }
    return;
}
