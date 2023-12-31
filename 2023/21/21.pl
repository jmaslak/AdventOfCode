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

use List::Util qw(min uniqstr);
use Digest::MD5 qw(md5_base64);

MAIN: {
    local $| = 1;
    my $t = Table->new();
    $t->read( *ARGV, sub { split // } );
    my $t2 = $t->copy();
    $t->add_border('#');

    my (@tmp) = $t->get_matching_coords( sub ($v) { $v eq 'S' } );
    my ($row, $col) = ($tmp[0]->row(), $tmp[0]->col());

    $t->put_xy($row, $col, '.');
    for my $row ($t->rows()) {
        $t->rows();
    }

    say "Spots part A: " . scalar(get_tiles_at_dist($t, $row, $col, 64));
    say "Spots part b: " . scalar(get_tiles_at_dist_infinite($t2, $row-1, $col-1, 1000));
}

sub get_tiles_at_dist($t, $row, $col, $steps) {
    my $rsize = $t->col_count();
    my (@spots) = map { $_->@* } $t->rows();

    my $pos = $row * $rsize + $col;

    my $visited = { $pos => 0 };
    my (@choices) = ( -$rsize, $rsize, -1, 1 );

    while ($steps) {
        my %newvisited;
        for my $pos (keys %$visited) {
            for my $choice (@choices) {
                if ($spots[$pos + $choice] ne '#') {
                    $newvisited{$pos + $choice} = 1;
                }
            }
        }
        $steps--;
        $visited = \%newvisited;
    }

    return keys %$visited;
}

sub get_tiles_at_dist_infinite($t, $row, $col, $steps) {
    my $cols = $t->col_count();
    my $rows = $t->row_count();

    my $visited = { "$row,$col" => [$row, $col, $row, $col] };
    my %satcheck;  # Saturation check

    my $prev = 0;
    my $cnt = 0;
    my $sat;
    while ($steps) {
        my %newvisited;
        for my $visit (values %$visited) {
            my ($row, $col, $vrow, $vcol) = $visit->@*;
            my (@next) = (
                [$row - 1, $col, ($vrow - 1) % $rows, $vcol],
                [$row + 1, $col, ($vrow + 1) % $rows, $vcol],
                [$row, $col - 1, $vrow, ($vcol - 1) % $cols],
                [$row, $col + 1, $vrow, ($vcol + 1) % $cols],
            );

            for my $pos (@next) {
                $pos->[4] = int($pos->[0] / $rows);
                $pos->[5] = int($pos->[1] / $cols);
                if ($t->get_xy($pos->[2], $pos->[3]) ne '#') {
                    $newvisited{$pos->[0] . ',' . $pos->[1]} = $pos;
                }
            }
        }
        $steps--;
        $visited = \%newvisited;

        $cnt++;
        my %plots;
        for my $v (values %$visited) {
            my $plot = $v->[4] . "," . $v->[5];
            if (!exists($plots{$plot})) { $plots{$plot} = [] };
            push $plots{$plot}->@*, $v;
        }

        for my $plot (sort keys %plots) {
            my $chk = md5_base64(join(":", uniqstr sort map { $_->[2] . ',' . $_->[3] } $plots{$plot}->@*));
            if (exists($satcheck{$chk})) {
                say "$plot " . scalar(keys %plots) . " SATURATED @ " . $satcheck{$chk}->[0] . " $chk " . $satcheck{$chk}->[1];
            } else {
                my $vcount = scalar(uniqstr sort map { $_->[2] . ',' . $_->[3] } $plots{$plot}->@*);
                say "$plot " . scalar(keys %plots) . "  not_sat  @ xxx " . " $chk $vcount";
                $satcheck{$chk} = [ $cnt, $vcount ];
            }
        }

        say "$cnt " . scalar(keys %plots) . " " . scalar(values %$visited) . " " . (scalar(values %$visited) - $prev);
        $prev = scalar(values %$visited);
    }

    return keys %$visited;
}

