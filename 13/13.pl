#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use lib '.';
use Table;

use List::Util qw(min);

MAIN: {
    my $t = Table->new();
    my $rowcount = 0;
    my $sum_a = 0;
    my $sum_b = 0;
    while (my $line = <<>>) {
        chomp($line);
        if ($line eq "") {
            $sum_a = $sum_a + get_smudged($t);
            $sum_b = $sum_b + get_unsmudged($t);
            $t = Table->new();
            $rowcount = 0;
        } else {
            my $colcount = 0;
            for my $c (split //, $line) {
                $t->put_xy($rowcount, $colcount, $c);
                $colcount++;
            }
            $rowcount++;
        }
    }
    $sum_a = $sum_a + get_smudged($t);
    $sum_b = $sum_b + get_unsmudged($t);

    say "Sum part A: $sum_a";
    say "Sum part B: $sum_b";
}

sub get_smudged($t1) {
    my $t2 = $t1->copy_swap_xy();
    my $sum = get_values($t1)->[0] + get_values($t2)->[0] * 100;
    return $sum;
}

sub get_unsmudged($t) {
    my $rows = $t->row_count();
    my $cols = $t->col_count();

    my $t1 = $t->copy();
    my $t2 = $t->copy_swap_xy();

    my $orig1 = get_values($t1);
    my $orig2 = get_values($t2);

    for (my $i=0; $i<$rows; $i++) {
        for (my $j=0; $j<$cols; $j++) {
            $t1->put_xy($i, $j, $t1->get_xy($i, $j) eq '.' ? '#' : '.' );
            $t2->put_xy($j, $i, $t2->get_xy($j, $i) eq '.' ? '#' : '.' );

            my $r1 = get_values($t1, [$orig1->[1], $orig1->[2]])->[0];
            my $r2 = get_values($t2, [$orig2->[1], $orig2->[2]])->[0];

            if ($r1 and $r2) {
                return $r1 + $r2 * 100;
            }
            if ($r1 and $r1 != $orig1->[0]) {
                return $r1;
            } elsif ($r2 and $r2 != $orig2->[0]) {
                return $r2 * 100;
            }

            $t1->put_xy($i, $j, $t1->get_xy($i, $j) eq '.' ? '#' : '.' );
            $t2->put_xy($j, $i, $t2->get_xy($j, $i) eq '.' ? '#' : '.' );
        }
    }

    return 0
}

sub get_values($t, $ignore = [-1, -1]) {
    my $cols = $t->col_count();
    for (my $i=1; $i<$cols; $i++) {
        my $dist = min ( $i, $cols-$i );
        my $left = $i-$dist;
        my $right = $i+$dist-1;

        if ($left == $ignore->[0] and $right == $ignore->[1]) { next; }

        my $flag=1;
        for (my $x=1; $x<=$dist; $x++) {
            my ($l) = join "", $t->get_col($left+$x-1);
            my ($r) = join "", $t->get_col($right-$x+1);

            if ($l ne $r) { $flag = undef; }
        }

        if ($flag) {
            return [$i, $left, $right];
        }
    }
    return [0, -1, -1];
}
