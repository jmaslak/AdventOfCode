#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use List::Util qw(min);
use Tree::Range;
use Tree::Range::RB;

MAIN: {
    my @map;
    while (my $line = <<>>) {
        chomp($line);
        @map = split //, $line;
    }

    my $state = "FILE";
    my $fileno = 0;
    my $range = Tree::Range->new("RB", { cmp => sub { $_[0] <=> $_[1] }, "equal-p" => \&equalp } );
    my $pos = 0;
    for my $ele (@map) {
        if ($state eq "FILE") {
            if ($ele > 0) {
                $range->range_set($pos, $pos+$ele, $fileno);
                $fileno++;
            }
            $state = "FREE";
        } else {
            $range->range_set($pos, $pos+$ele, "free") unless $ele eq 0;
            $state = "FILE";
        }
        $pos += $ele;
    }

    my $r = copy_range($range);

    # Defragment
    print_range($range);

    my $defrag = defrag($range, 0);
    say "Part 1: " . checksum_range($defrag);

    $defrag = defrag($range, 1);
    # print_range($defrag);
    say "Part 2: " . checksum_range($defrag);
}

sub equalp($v1, $v2) {
    if (!defined($v1) && !defined($v2)) {
        return 1;
    }
    if (!defined($v1) || !defined($v2)) {
        return undef;
    }
    return $v1 eq $v2;
}

sub checksum_range($range) {
    my $sum = 0;
    my $ic = $range->range_iter_closure();
    while (my (@node) = $ic->()) {
        if (!defined($node[2])) { last }
        if (($node[0] // "free") eq "free") { 
            next;
        }

        for (my $i=$node[1]; $i<$node[2]; $i++) {
            $sum += $i * $node[0];
        }
    }
    say "";
    return $sum;
}

sub copy_range($range) {
    my $new = Tree::Range->new("RB", { cmp => sub { $_[0] <=> $_[1] }, "equal-p" => \&equalp } );
    my $ic = $range->range_iter_closure(0);
    my $max = 0;
    while (my (@node) = $ic->()) {
        if (!defined($node[2])) { return $new; }
        $new->range_set($node[1], $node[2], $node[0]);
    }
}

sub get_max($range) {
    my $ic = $range->range_iter_closure(0);
    my $max = 0;
    while (my (@node) = $ic->()) {
        if (!defined($node[2])) { return $max; }
        $max = $node[2] - 1;
    }
}

sub defrag($range, $method) {
    $range = copy_range($range);

    my $max = get_max($range);
    my $pos = $max;
    my $free = 0;
    my $minfree = undef;

    while (1) {
        my (@data_node) = $range->get_range($pos);
        my (@free_node) = $range->get_range($free);

        if (!defined($free_node[0])) { last }
        if (!defined($data_node[0])) { last }
        if (($minfree // 0) > $pos) {
            last;
        }
        if ($free > $pos) { 
            if ($method == 0) {
                last;
            } else {
                $pos = $data_node[1] - 1;
                $free = 0;
                say "Going back";
                next;
            }
        }

        if ($free_node[0] ne "free") { 
            $free = $free_node[2];
            next;
        }

        if (!defined($minfree)) {
            $minfree = $free;
        }

        if ($data_node[0] eq "free") {
            $pos = $data_node[1] - 1;
            next;
        }

        my $free_len = $free_node[2] - $free_node[1];
        my $data_len = $data_node[2] - $data_node[1];

        if ($method == 1) {
            if ($free_len < $data_len) {
                $free = $free_node[2];
                next;
            }
        }

        my $len = min ($free_len, $data_len);

        $range->range_set($pos-$len+1, $pos+1, "free");
        $range->range_set($free, $free+$len, $data_node[0]);

        if ($method == 1) {
            $free = $minfree;
            if ($free_node[1] == $minfree) {
                $minfree = undef;
            }
        }
    }

    return $range;
}

sub print_range($range) {
    my $ic = $range->range_iter_closure(0);
    my $max = 0;
    while (my (@node) = $ic->()) {
        if (!defined($node[2])) { last }
        for (my $i=$node[1]; $i<$node[2]; $i++) {
            print ($node[0] eq 'free' ? '.' : $node[0]);
        }
    }
    say "";
}
