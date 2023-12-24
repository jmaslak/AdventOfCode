#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
no warnings 'recursion';    # We know it does deep recursion!
use experimental 'args_array_with_signatures';

use Inline 'C';

use lib '.';
use Table;

use List::Util qw(max);
use Time::HiRes;

MAIN: {
    local $| = 1;
    my $t = Table->new();
    $t->read( *ARGV, sub { split // } );
    my $visited = $t->copy();

    my @rowarray = $t->row(0)->@*;
    my $start;
    for my $i ( 0 .. ( $t->col_count() - 1 ) ) {
        if ( $rowarray[$i] eq '.' ) {
            $start = $i;
            last;
        }
    }
    die if !defined($start);

    my $longpath = build_graph($t);
    say "Path length Part B: $longpath";
}

sub build_graph ($t) {
    my $rowcount = $t->row_count();
    my $colcount = $t->col_count();

    my %graph;
    my $pos;

    for my $row ( 1 .. ( $rowcount - 2 ) ) {
        for my $col ( 1 .. ( $colcount - 2 ) ) {
            my $directions = 0;
            for my $dir ( [ -1, 0 ], [ 1, 0 ], [ 0, -1 ], [ 0, 1 ] ) {
                if ( $t->get_xy( $row + $dir->[0], $col + $dir->[1] ) =~ /[v<>^]/ ) {
                    $directions++;
                }
            }
            if ( $directions >= 3 ) {
                $graph{"$row,$col"} =
                  [];    # Will be array of arrays, inner array is next point and distance.
            }
        }
    }

    my $start;
    for my $i ( 0 .. ( $t->col_count() - 1 ) ) {
        if ( $t->get_xy( 0, $i ) eq '.' ) {
            $start = "0,$i";
            $graph{$start} = [];
            last;
        }
    }
    my $end;
    for my $i ( 0 .. ( $t->col_count() - 1 ) ) {
        if ( $t->get_xy( $rowcount - 1, $i ) eq '.' ) {
            $end = ( $rowcount - 1 ) . ",$i";
            $graph{$end} = [];
            last;
        }
    }

    for my $k ( keys %graph ) {
        my @next = find_next( $t, \%graph, $k );
        push $graph{$k}->@*, @next;
    }

    my %decoder;
    my $i;
    for my $k (keys %graph) {
        $decoder{$k} = $i++;
    }

    init_graph(scalar(keys %graph));

    my @grapharray;
    for my $k (keys %decoder) {
        my $i = $decoder{$k};

        my (@edges) = $graph{$k}->@*;
        for my $j (0..$#edges) {
            my @edge = $edges[$j]->@*;
            set_edge($i, $j, $decoder{$edge[0]}, $edge[1]);
        }
    }

    my $tm = Time::HiRes::time();
    my $pl = longest_path($decoder{$start}, $decoder{$end});
    cleanup();
    say "Time spent: ". (Time::HiRes::time()-$tm);
    return $pl;
}

sub find_next ( $t, $graph, $start ) {
    my @out;
    for my $dir ( [ -1, 0 ], [ 1, 0 ], [ 0, -1 ], [ 0, 1 ] ) {
        my ( $row, $col ) = split ",", $start;
        $row += $dir->[0];
        $col += $dir->[1];
        if ( $row < 0                or $col < 0 )                { next; }
        if ( $row >= $t->row_count() or $col >= $t->col_count() ) { next; }

        my %visited;
        $visited{$start} = 1;

        if ( $t->get_xy( $row, $col ) !~ m/[.v<>^]/ ) { next; }

        my $cnt = 1;

        $visited{"$row,$col"} = 1;
      MEANWHILE:
        while (1) {
            $cnt++;
            my ( $i, $j );
            for my $dir ( [ -1, 0 ], [ 1, 0 ], [ 0, -1 ], [ 0, 1 ] ) {
                $i = $row + $dir->[0];
                $j = $col + $dir->[1];

                if ( exists( $visited{"$i,$j"} ) ) { next; }
                $visited{"$i,$j"} = 1;

                if ( $t->get_xy( $i, $j ) !~ m/[.v<>^]/ ) { ; next; }
                if ( exists( $graph->{"$i,$j"} ) ) {
                    push @out, [ "$i,$j", $cnt ];
                    last MEANWHILE;
                }
                last;
            }
            $row = $i;
            $col = $j;
        }
    }
    return @out;
}

__DATA__
__C__
struct edge {
    int next;
    int cost;
};

struct node {
    struct edge edge[4];
};

int elems;
struct node * graph;

void init_graph(int len) {
    elems = len;
    graph = malloc(sizeof(struct node) * len);
    for (int i=0; i<elems; i++) {
        for (int j=0; j<4; j++) {
            graph[i].edge[j].cost = 0;
        }
    }
}

void cleanup() {
    free(graph);
}

void set_edge(int node, int edgeid, int next, int cost) {
    graph[node].edge[edgeid].cost = cost;
    graph[node].edge[edgeid].next = next;
}

int longest_path_recurse(int start, int end, bool * visited) {
    if (start == end) { return 0; }
    visited[start] = true;

    int max = -1;
    bool * visited_new = malloc(sizeof(bool) * elems);
    memcpy(visited_new, visited, sizeof(bool) * elems);
    int dirty = 0;
    for (int i=0; i<4; i++) {
        if (graph[start].edge[i].cost > 0) {
            int next = graph[start].edge[i].next;
            if (visited[next]) continue;

            int cost = graph[start].edge[i].cost;
            if (cost == -1) { break; }
            
            if (dirty++) {
                memcpy(visited_new, visited, sizeof(bool) * elems);
            }
            int lp = longest_path_recurse(next, end, visited_new);  // Speed optimization
            if (lp >= 0) {
                if (lp + cost > max) max = lp + cost;
            }
        }
    }
    free(visited_new);

    return max;
}

int longest_path(int start, int end) {
    bool * visited = malloc(sizeof(bool) * elems);
    for (int i=0; i<elems; i++) visited[i] = false;
    int ret = longest_path_recurse(start, end, visited);
    free(visited);
    return ret;
}
