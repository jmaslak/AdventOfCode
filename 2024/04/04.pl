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
    $table->read(\*STDIN);
    my $part1 = 0;
    my $part2 = 0;
    for (my $row=0; $row < $table->row_count(); $row++) {
        for (my $col=0; $col < $table->col_count(); $col++) {
            my (@words) = get_all($table, $row, $col, 4);
            @words = grep /^XMAS$/i, @words;
            $part1 += scalar(@words);

            if (get_diag($table, $row, $col)) {
                $part2++;
            }
        }
    }

    say "Part1: $part1";
    say "Part2: $part2";
}

sub get_all($table, $row, $col, $len) {
    my $rows = $table->row_count();
    my $cols = $table->col_count();

    my @words;
    if ($row + 1 - $len >= 0) {
        # Up
        push @words, get_word($table, $len, $row, $col, -1, 0);
        if ($col + 1 - $len >= 0) {
            # Left
            push @words, get_word($table, $len, $row, $col, -1, -1);
        }
        if ($col + $len <= $cols) {
            # Right
            push @words, get_word($table, $len, $row, $col, -1, +1);
        }
    }
    if ($row + $len <= $rows) {
        # down
        push @words, get_word($table, $len, $row, $col, +1, 0);
        if ($col + 1 - $len >= 0) {
            # Left
            push @words, get_word($table, $len, $row, $col, +1, -1);
        }
        if ($col + $len <= $cols) {
            # Right
            push @words, get_word($table, $len, $row, $col, +1, +1);
        }
    }
    if ($col + 1 - $len >= 0) {
        # Left
        push @words, get_word($table, $len, $row, $col, 0, -1);
    }
    if ($col + $len <= $cols) {
        # Right
        push @words, get_word($table, $len, $row, $col, 0, +1);
    }

    return @words;
}

sub get_diag($table, $row, $col) {
    my $rows = $table->row_count();
    my $cols = $table->col_count();

    if ($row == 0) { return undef }
    if ($col == 0) { return undef }
    if ($row == $rows-1) { return undef }
    if ($col == $cols-1) { return undef }

    my $c = Coord->new(row => $row, col => $col);

    my $word1 = $table->get($c->nw()) . $table->get($c) . $table->get($c->se());
    my $word2 = $table->get($c->ne()) . $table->get($c) . $table->get($c->sw());

    if (!(($word1 eq 'MAS') or ($word1 eq 'SAM'))) { return undef }
    if (!(($word2 eq 'MAS') or ($word2 eq 'SAM'))) { return undef }

    return 1;
}

sub get_word($table, $len, $row, $col, $delta_row, $delta_col) {
    my $word = "";
    for (my $i=0; $i < $len; $i++) {
        $word .= $table->get_xy($row, $col);
        $row += $delta_row;
        $col += $delta_col;
    }
    return $word;
}
