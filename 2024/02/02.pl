#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use lib '.';
use List::Util qw(sum);
use Table;

MAIN: {
    my $table = Table->new();
    $table->read(*STDIN, sub { split /\s+/ } );

    my $count_safe = sum map { is_safe($_) // 0 } $table->rows();
    say "Part 1: $count_safe";
    
    $count_safe = sum map { is_safeish($_) // 0 } $table->rows();
    say "Part 2: $count_safe";
}

sub is_safe($row) {
    my $direction;
    my $last;
    for my $ele (@$row) {
        if (!defined($ele) or $ele eq 'u') {
            next;
        }

        if (!defined($last)) {
            $last = $ele;
            next;
        }

        if (!defined($direction)) {
            $direction = $last <=> $ele;
        }
        if ($direction == 0) {
            return undef;
        }

        if (($last <=> $ele) != $direction) {
            return undef;
        }

        if (abs($ele - $last) > 3) {
            return undef;
        }

        $last = $ele;
    }
    return 1;
}

sub is_safeish($row) {
    for (my $i=0; $i<scalar(@$row); $i++) {
        my (@newrow) = @$row;
        $newrow[$i] = 'u';
        if (is_safe(\@newrow)) {
            return 1;
        }
    }

    return undef;
}

sub compare($list1, $list2) {
    if (scalar(@$list1) != scalar(@$list2)) { return undef }
    for (my $i=0; $i<scalar(@$list1); $i++) {
        if ($list1->[$i] != $list2->[$i]) { return undef }
    }

    return 1;
}

