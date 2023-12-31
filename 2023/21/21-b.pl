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

use List::Util qw(min max uniqstr any);
use Digest::MD5 qw(md5_base64);
use Data::Dump;
use Math::NumSeq::Triangular;

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

    # say "Spots part A: " . scalar(get_tiles_at_dist($t, $row, $col, 64));
    # say "Spots part b: " . scalar(get_tiles_at_dist_infinite($t2, $row, $col, 1000));
    $row--; $col--;   # Subtract border
    my $center = [build_sequence($t2, $row, $col)];
    my (@straight) = (
        [build_sequence($t2, $row, 0)],  # Right
        [build_sequence($t2, $row, $t2->col_count()-1)],  # Left
        [build_sequence($t2, 0, $col)],  # Down
        [build_sequence($t2, $t2->row_count()-1, $col)],  # Up
    );

    my (@diag) = (
        [build_sequence($t2, 0, 0)],  # Down, Right
        [build_sequence($t2, 0, $t2->col_count()-1)],  # Down, Left
        [build_sequence($t2, $t2->row_count()-1, 0)],  # Up, Right
        [build_sequence($t2, $t2->row_count()-1, $t2->col_count()-1)],  # Up, Left
    );

    my $plots = 0;
    my $steps = 26501365;

    # Add center
    $plots += $center->[2][($steps - $center->[1]) % 2];

    {
        my $mid = $t2->row_count() - $row;
        my $rsize = $t2->row_count();

        # Add long dimensions
        my $dist = int(($steps-$mid) / $rsize);  # We know this from input
        say "Distance is $dist";
        for my $field (@straight) {
            say $field->[2][($steps - $field->[1]) % 2] * $dist;
            $plots += $field->[2][($steps - $field->[1]) % 2] * $dist;
            my $leftover = ($steps - 1 - $row) % $rsize;
            say "LEFTOVER: $leftover";
            # if ($leftover > $field->[1]) { die "We expect not to be repeating"; }
            say $field->[0][$leftover];
            $plots += $field->[0][$leftover];
        }

        my $seq = int(($steps-1) / $rsize);  # We know this from input
        my ($full_even, $full_odd) = get_ab($seq-2);
        my ($last_even, $last_odd) = get_ab($seq);
        my $diff_even = $last_even - $full_even;
        my $diff_odd  = $last_odd - $full_odd;
        for my $field (@diag) {
            $plots += $field->[2][0] * $full_even;
            $plots += $field->[2][1] * $full_odd;

            my $leftover_even = ($steps - $field->[1] - (1 + $rsize)) % $rsize;
            my $leftover_odd = ($steps - $field->[1] - (1 + $rsize * 2)) % $rsize;
                say $rsize;
            say "LEFTOVER EVEN: $leftover_even";
            say "LEFTOVER ODD : $leftover_odd";
            $plots += $field->[0][$leftover_even] * $diff_even;
            $plots += $field->[0][$leftover_odd] * $diff_odd;
        }

        say $plots;
    }
}

sub get_ab($seq) {
    if ($seq == 0) { return 0,0 }
    my $aseq = int((1+$seq) / 2);
    my $a = $aseq * $aseq;
    my $b = Math::NumSeq::Triangular->new()->ith($seq) - $a;

    return $a, $b;
}

sub build_sequence($t_orig, $row, $col) {
    my $t = $t_orig->copy();
    $t->add_border("#");

    my $rsize = $t->col_count();
    my (@spots) = map { $_->@* } $t->rows();

    my $pos = [$row + 1, $col + 1];

    my $visited = { (($row+1) . "," . ($col+1) ) => $pos };
    my $oldhash = "START";
    my (@choices) = ( [-1, 0], [1, 0], [0, -1], [0, 1] );

    my %links;  # Indexes into "next" md5 and tracks when first seen.
    $links{$oldhash} = {
        step => 0,
        next => undef
    };

    my $cnt = 0;
    my @sequence;
    while (1) {
        $cnt++;

        my %newvisited;
        for my $pos (values %$visited) {
            for my $choice (@choices) {
                my $row = $pos->[0] + $choice->[0];
                my $col = $pos->[1] + $choice->[1];
                if ($spots[$row * $rsize + $col] ne '#') {
                    # if ($t->get_xy($row, $col) ne '#') {
                    $newvisited{"$row,$col"} = [$row, $col];
                }
            }
        }

        $visited = \%newvisited;
        my $md5 = get_hashval($visited);
        my $plots = scalar(keys %$visited);

        if (defined($links{$oldhash}->{next})) {
            if ($links{$oldhash}->{next} ne $md5) {
                die "OH NO, non-determanistic!";
            }
        } else {
            $links{$oldhash}->{next} = $md5;
        }
        $oldhash = $md5;

        if (!exists($links{$md5})) {
            push @sequence, $plots;
            $links{$md5} = {
                step => $cnt,
                next => undef
            }
        } else {
            say "Loop found at step $cnt, looping back to " . $links{$md5}->{step};
            say "Plots: " . $plots;
            if ($cnt - $links{$md5}->{step} != 2) { die "Loop is not two steps!" }
            last;
        }
    }

    my @repeat;
    $repeat[1] = pop @sequence;
    $repeat[0] = pop @sequence;
    unshift @sequence, 1;
    my $seqlen = scalar(@sequence);

    return \@sequence, $seqlen, \@repeat;
}
            
sub get_hashval($visited) {
    return md5_base64(join(":", sort keys %$visited));
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
                $pos->[4] = int(($pos->[0] - ($pos->[0] < 0 ? $rows - 1 : 0)) / $rows);
                $pos->[5] = int(($pos->[1] - ($pos->[1] < 0 ? $cols - 1 : 0)) / $cols);
                if ($pos->[4] < -1 or $pos->[4] > 0 or $pos->[5] < -1 or $pos->[5] > 0) { next; }
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
                say "$plot " . $cnt . " SATURATED @ " . $satcheck{$chk}->[0] . " $chk " . $satcheck{$chk}->[1];
            } else {
                my $vcount = scalar(uniqstr sort map { $_->[2] . ',' . $_->[3] } $plots{$plot}->@*);
                say "$plot " . $cnt . "  not_sat  @ xxx " . " $chk $vcount";
                $satcheck{$chk} = [ $cnt, $vcount ];
            }
        }

        say "$cnt " . scalar(keys %plots) . " " . scalar(values %$visited) . " " . (scalar(values %$visited) - $prev);
        $prev = scalar(values %$visited);
    }

    return keys %$visited;
}

