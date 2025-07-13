#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use lib '.';
use Table;
use List::Util qw(first uniqstr min);

my (%directions) = (
    w => '<',
    e => '>',
    n => '^',
    s => 'v',
);

MAIN: {
    my $numberpad = Table->new();
    $numberpad->read(\*DATA);

    my $arrowpad = Table->new();
    $arrowpad->read(\*DATA);

    $arrowpad->add_border('x');
    $numberpad->add_border('x');

    my @lines;
    while (<STDIN>) {
        chomp;
        if ($_ eq "") { next }
        push @lines, $_;
    }

    my $robots = $ARGV[0] // 2;

    my $part1 = 0;
    for my $combo (@lines) {
        my $iterate = sequence($numberpad, 'A', $combo, 0);

        for (my $i=0; $i<$robots; $i++) {
            $iterate = iterate($arrowpad, $iterate);
        }

        my ($num) = $combo =~ /^(\d+).*/;
        my $len = length($iterate);
        $part1 += $num * $len;
    }

    say "Part 1: $part1";
}

sub iterate($t, $seq) {
    state %cache;
    if (!exists($cache{$seq})) {
        my $combo = "";
        for my $ele (split /A/, $seq) {
            my $part = $ele . "A";
            $combo .= sequence($t, "A", $part, 1);
        }

        $cache{$seq} = $combo;
    }

    return $cache{$seq};
}


sub sequence($t, $start_c, $seq, $type) {
    state %cache;
    my $key = "$start_c $seq";
    if (!exists($cache{$key})) {
        if ($seq eq "") {
            $cache{$key} = "";
        } else {
            my ($next, $rest) = $seq =~ /^(.)(.*)$/;
            my $rests = sequence($t, $next, $rest, $type);
            my $nexts = move($t, $start_c, $next, $type);
            $cache{$key} = $nexts . "A" . $rests;
        }
    }
    return $cache{$key};
}


sub move($t, $start_c, $end_c, $type) {
    state %cache;
    my $key = "$start_c$end_c";
    if (!exists($cache{$key})) {
        my $start = first { 1 } $t->find($start_c);
        my $end   = first { 1 } $t->find($end_c);

        my $result = "";
        if ($start->col < $end->col) {
            if ($start->row > $end->row) {
                if ($type) {
                    $result .= ">" x ($end->col - $start->col);
                    $result .= "^" x ($start->row - $end->row);
                } else {
                    $result .= ">" x ($end->col - $start->col);
                    $result .= "^" x ($start->row - $end->row);
                }
            } else {
                if ($type) {
                    $result .= ">" x ($end->col - $start->col);
                    $result .= "v" x ($end->row - $start->row);
                } else {
                    if ($start->col == 1 and $end->row == 4) {
                        $result .= ">" x ($end->col - $start->col);
                        $result .= "v" x ($end->row - $start->row);
                    } else {
                        $result .= "v" x ($end->row - $start->row);
                        $result .= ">" x ($end->col - $start->col);
                    }
                }
            }
        } else {
            if ($start->row > $end->row) {
                if ($type) {
                    $result .= "<" x ($start->col - $end->col);
                    $result .= "^" x ($start->row - $end->row);
                } else {
                    if ($start_c eq "A" and ($start->col - $end->col) == 2) {
                        $result .= "^" x ($start->row - $end->row);
                        $result .= "<" x ($start->col - $end->col);
                    } else {
                        # CHECK
                        $result .= "<" x ($start->col - $end->col);
                        $result .= "^" x ($start->row - $end->row);
                    }
                }
            } else {
                if ($type) {
                    $result .= "v" x ($end->row - $start->row);
                    $result .= "<" x ($start->col - $end->col);
                } else {
                    $result .= "<" x ($start->col - $end->col);
                    $result .= "v" x ($end->row - $start->row);
                }
            }
        }
        $cache{$key} = $result;
    }
    return $cache{$key};
}


__DATA__
789
456
123
x0A

x^A
<v>

__END__
