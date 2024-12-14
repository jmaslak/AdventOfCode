#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use List::Util qw(reduce);
use lib '.';
use Table;

class Robot {
    field $x     :reader;
    field $y     :reader;
    field $vx    :reader;
    field $vy    :reader;

    field $init_x;
    field $init_y;

    field $max_x :reader :param;
    field $max_y :reader :param;

    method set_x($val)  { $x  = $val; if (!defined($init_x)) { $init_x = $x } }
    method set_y($val)  { $y  = $val; if (!defined($init_y)) { $init_y = $y } }
    method set_vx($val) { $vx = $val }
    method set_vy($val) { $vy = $val }

    method move($moves) {
        $x = ($moves * $vx + $x) % $max_x;
        $y = ($moves * $vy + $y) % $max_y;
    }

    method quad() {
        my $mid_x = int(($max_x - 1) / 2);
        my $mid_y = int(($max_y - 1) / 2);

        if (($x < $mid_x) and ($y < $mid_y)) { return 0 }
        if (($x > $mid_x) and ($y < $mid_y)) { return 1 }
        if (($x < $mid_x) and ($y > $mid_y)) { return 2 }
        if (($x > $mid_x) and ($y > $mid_y)) { return 3 }
        return undef;
    }

    method reset() {
        $x = $init_x;
        $y = $init_y;
    }
}

MAIN: {
    my $cols;
    my $rows;
    my @robots;

    while (my $line = <<>>) {
        chomp($line);
        if ($line =~ /^xy=/) {
            ($cols, $rows) = $line =~ /(\d+),(\d+)/;
        } else {
            my $robot = Robot->new(max_x => $cols, max_y => $rows);
            my ($x, $y, $vx, $vy) = $line =~ /^p=([^,]+),([^ ]+) v=([^,]+),(.+)$/;

            $robot->set_x($x);
            $robot->set_y($y);
            $robot->set_vx($vx);
            $robot->set_vy($vy);

            push @robots, $robot;
        }
    }

    move_all(\@robots, 100);
    my $part1 = reduce { $a * $b } get_quad_counts(\@robots);
    say "Part1: $part1";

    my $table = Table->new();
    $table->put_xy($robots[0]->max_y, $robots[0]->max_x, ' ');

    my $moves = 0;
    reset_all(\@robots);
    while (1) {
        my (@quads) = get_quad_counts(\@robots);
        if (is_tree(\@robots)) {
            say "Part2: $moves";
            print_design(\@robots);
            last;
        }

        $moves++;
        move_all(\@robots, 1);
    }
}

sub print_design($robots) {
    my $table = Table->new();
    $table->put_xy($robots->[0]->max_y, $robots->[0]->max_x, ' ');
    $table->fill(' ');

    for my $robot (@$robots) {
        $table->put_xy($robot->y, $robot->x, "*");
    }

    $table->print_table();
}

sub move_all($robots, $moves) {
    for my $robot ($robots->@*) {
        $robot->move($moves);
    }
}

sub reset_all($robots) {
    for my $robot ($robots->@*) {
        $robot->reset();
    }
}

sub get_quad_counts($robots) {
    my (@counts) = (0, 0, 0, 0);
    for my $robot ($robots->@*) {
        my $val = $robot->quad();
        if (defined($val)) {
            $counts[$val]++;
        }
    }
    return @counts;
}

sub is_tree($robots) {
    # We will look for a bunch of blank rows and columns.
    my (@x) = map { $_->x } @$robots;
    my (@y) = map { $_->y } @$robots;
    my @rows;
    for my $x (@x) {
        $rows[$x]++;
    }
    my @cols;
    for my $y (@y) {
        $cols[$y]++;
    }

    my $none_rows = 0;
    my $none_cols = 0;
    for my $row (@rows) {
        if (($row // 0) == 0) { $none_rows++ };
    }
    for my $col (@cols) {
        if (($col // 0) == 0) { $none_cols++ };
    }
    return (($none_cols > 15) and ($none_rows > 15));
}
