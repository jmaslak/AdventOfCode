#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use lib '.';
use Table;

use List::Util qw(all);

MAIN: {
    my $t = Table->new();
    $t->read( *ARGV, sub { split // } );

    my (@empty_row) = grep { all { $_ eq '.' } $t->get_row($_) } 0 .. ( $t->row_count() - 1 );
    my (@empty_col) = grep { all { $_ eq '.' } $t->get_col($_) } 0 .. ( $t->col_count() - 1 );

    my $matcher  = sub ($v) { return ( $v eq '#' ); };
    my @galaxies = $t->get_matching_coords($matcher);

    my $sum = get_sums( $t, 2, \@empty_row, \@empty_col, \@galaxies );
    say("Part A Sum: $sum");

    $sum = get_sums( $t, 1_000_000, \@empty_row, \@empty_col, \@galaxies );
    say("Part B Sum: $sum");
}

sub get_sums ( $t, $expansion, $empty_row, $empty_col, $galaxies ) {
    my $sum = 0;
    for ( my $i = 0; $i < scalar(@$galaxies) - 1; $i++ ) {
        for ( my $j = $i + 1; $j < scalar(@$galaxies); $j++ ) {
            $sum +=
              dist( $t, $expansion, $empty_row, $empty_col, $galaxies->[$i], $galaxies->[$j] );
        }
    }
    return $sum;
}

sub dist ( $t, $expansion, $empty_row, $empty_col, $coord1, $coord2 ) {
    my (@rows) = sort { $a <=> $b } ( $coord1->row(), $coord2->row() );
    my (@cols) = sort { $a <=> $b } ( $coord1->col(), $coord2->col() );

    my (@rowexpand) = grep { $rows[0] < $_ and $rows[1] > $_ } @$empty_row;
    my (@colexpand) = grep { $cols[0] < $_ and $cols[1] > $_ } @$empty_col;

    return $rows[1] - $rows[0] + $cols[1] - $cols[0] + ( scalar(@rowexpand) * $expansion ) +
      ( scalar(@colexpand) * $expansion ) - scalar(@rowexpand) - scalar(@colexpand);
}

