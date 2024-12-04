#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use lib '.';
use Table;

MAIN: {
    my $table = Table->new();
    $table->read( \*STDIN );
    my $part1 = 0;
    my $part2 = 0;
    for ( my $row = 0; $row < $table->row_count(); $row++ ) {
        for ( my $col = 0; $col < $table->col_count(); $col++ ) {
            $part1 += scalar grep /^XMAS$/,
              grep { defined } $table->get_all_runs_from_xy( $row, $col, 4 );

            if ( get_diag( $table, $row, $col ) ) {
                $part2++;
            }
        }
    }

    say "Part1: $part1";
    say "Part2: $part2";
}

sub get_diag ( $table, $row, $col ) {
    my $rows = $table->row_count();
    my $cols = $table->col_count();

    if ( $row == 0 )         { return undef }
    if ( $col == 0 )         { return undef }
    if ( $row == $rows - 1 ) { return undef }
    if ( $col == $cols - 1 ) { return undef }

    my $c = Coord->new( row => $row, col => $col );

    my $word1 = $table->get( $c->nw() ) . $table->get($c) . $table->get( $c->se() );
    my $word2 = $table->get( $c->ne() ) . $table->get($c) . $table->get( $c->sw() );

    if ( !( ( $word1 eq 'MAS' ) or ( $word1 eq 'SAM' ) ) ) { return undef }
    if ( !( ( $word2 eq 'MAS' ) or ( $word2 eq 'SAM' ) ) ) { return undef }

    return 1;
}
