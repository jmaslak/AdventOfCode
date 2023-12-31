#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
no warnings 'recursion';    # We know it does deep recursion!

use lib '.';
use Table;

use Data::Dump;
use List::Util qw(max min sum);

my %directions = (
    U => [ -1, 0 ],
    D => [ 1,  0 ],
    L => [ 0,  -1 ],
    R => [ 0,  1 ],
);

my %colormap = (
    0 => 'R',
    1 => 'D',
    2 => 'L',
    3 => 'U',
);

MAIN: {
    my @directions1;
    my @directions2;
    my (@offset1)  = ( 0, 0 );
    my (@running1) = ( 0, 0 );
    my (@offset2)  = ( 0, 0 );
    my (@running2) = ( 0, 0 );

    while (my $line = <<>> ) {
        chomp($line);
        my ( $dir, $len, $hexdist, $hexcolor ) = $line =~ m/^([RLDU]) (\d+) ..(.....)(.).$/;
        push @directions1, [ $dir, $len ];
        push @directions2, [ $colormap{$hexcolor}, hex($hexdist) ];

        my $d = $dir;
        if    ( $d eq 'U' ) { $running1[0] -= $len }
        elsif ( $d eq 'D' ) { $running1[0] += $len }
        elsif ( $d eq 'L' ) { $running1[1] -= $len }
        elsif ( $d eq 'R' ) { $running1[1] += $len }

        $offset1[0] = min $running1[0], $offset1[0];
        $offset1[1] = min $running1[1], $offset1[1];

        $d = $colormap{$hexcolor};
        if    ( $d eq 'U' ) { $running2[0] -= hex($hexdist) }
        elsif ( $d eq 'D' ) { $running2[0] += hex($hexdist) }
        elsif ( $d eq 'L' ) { $running2[1] -= hex($hexdist) }
        elsif ( $d eq 'R' ) { $running2[1] += hex($hexdist) }

        $offset2[0] = min $running2[0], $offset2[0];
        $offset2[1] = min $running2[1], $offset2[1];
    }

    my ( $t, $rows, $cols ) = create_sparse_table( $offset1[0], $offset1[1], \@directions1 );
    my $sum = find_size( $t, $rows, $cols );
    say "Part A count: $sum";

    ( $t, $rows, $cols ) = create_sparse_table( $offset2[0], $offset2[1], \@directions2 );
    $sum = find_size( $t, $rows, $cols );
    say "Part B count: $sum";
}

sub find_size ( $t, $rows, $cols ) {
    my $flood = Table->new();
    my $cc = $t->col_count();

    my @cache;  # Visited cache, speed optimizaton.
    @cache[$cc * $t->row_count()] = undef;

    my @stack;
    push @stack, [0, 0];
    while ( my $ele = shift @stack ) {
        if (defined $cache[$ele->[0] * $cc + $ele->[1]]) { next; }
        $cache[$ele->[0] * $cc + $ele->[1]] = 1;
        if ( ( $flood->get_xy(@$ele) // '.' ) ne '.' ) {
            # Do nothing
        } elsif ( ( $t->get_xy(@$ele) // 'E' ) ne '#' ) {
            $flood->put_xy( @$ele, 'E' );
            push @stack, $t->neighbors_xy( @$ele, undef );
        }
    }

    my $sum = 0;
    for ( my $row = 0; $row < $t->row_count(); $row++ ) {
        for ( my $col = 0; $col < $t->col_count(); $col++ ) {
            my $c = $flood->get_xy( $row, $col );
            if ( ( $c // "#" ) eq "#" ) {
                if ( !defined($rows) ) {
                    $sum++;
                } else {
                    $sum += $rows->[$row] * $cols->[$col];
                }
            }
        }
    }

    return $sum;
}

sub create_sparse_table ( $offset_row, $offset_col, $directions ) {
    my %steps = ( rows => {}, cols => {} );

    my (@running) = ( -$offset_row, -$offset_col );
    for my $direction (@$directions) {
        my ( $dir, $len ) = @$direction;
        $running[0] += $directions{$dir}[0] * $len;
        $running[1] += $directions{$dir}[1] * $len;
        $steps{rows}->{ $running[0] } = 1;
        $steps{cols}->{ $running[1] } = 1;
    }

    my (@r) = sort { $a <=> $b } keys $steps{rows}->%*;
    my (@c) = sort { $a <=> $b } keys $steps{cols}->%*;

    # Compute weights
    my $last = undef;
    for my $row (@r) {
        if ( defined($last) ) {
            if ( ( $last + 1 ) != $row ) {
                $steps{rows}->{ $last + 1 } = $row - $last - 1;
            }
        }
        $last = $row;
    }
    $last = undef;
    for my $col (@c) {
        if ( defined($last) ) {
            if ( ( $last + 1 ) != $col ) {
                $steps{cols}->{ $last + 1 } = $col - $last - 1;
            }
        }
        $last = $col;
    }

    my @rows;
    for my $row ( sort { $a <=> $b } keys $steps{rows}->%* ) {
        push @rows, $row;
    }
    my @cols;
    for my $col ( sort { $a <=> $b } keys $steps{cols}->%* ) {
        push @cols, $col;
    }

    my $t = Table->new();
    @running = ( -$offset_row, -$offset_col );
    for my $direction (@$directions) {
        my ( $dir, $len ) = @$direction;

        my (@start) = ( $running[0], $running[1] );
        $running[0] += $directions{$dir}[0] * $len;
        $running[1] += $directions{$dir}[1] * $len;

        my $minx = min $running[0], $start[0];
        my $maxx = max $running[0], $start[0];
        for ( my $row = 0; $row < scalar(@rows); $row++ ) {
            if ($maxx < $rows[$row]) { last; }
            if ( $minx <= $rows[$row] ) {
                my $miny = min $running[1], $start[1];
                my $maxy = max $running[1], $start[1];
                for ( my $col = 0; $col < scalar(@cols); $col++ ) {
                    if ( $maxy < $cols[$col] ) { last; }
                    if ( $miny <= $cols[$col] ) {
                        $t->put_xy( $row, $col, '#' );
                    }
                }
            }
        }
    }

    push @rows, 0;
    push @cols, 0;
    unshift @rows, 0;
    unshift @cols, 0;

    $t->add_border(".");

    my (@return_row) = map { $steps{rows}->{$_} } @rows;
    my (@return_col) = map { $steps{cols}->{$_} } @cols;

    return $t, \@return_row, \@return_col;
}
