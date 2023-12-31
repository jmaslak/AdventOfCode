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

use List::Util qw(max);

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

    my $longpath = visit( $t, 0, $start, 0 );
    say "Path length Part A: $longpath";

    $longpath = build_graph($t);
    say "Path length Part B: $longpath";
}

sub visit ( $start_t, $start_row, $start_col, $mountaineer, $initial = -1 ) {
    my (@table);
    push @table, map { $_->@* } $start_t->rows();
    my $rowcount = $start_t->row_count();
    my $colcount = $start_t->col_count();

    my (@coords) = $start_t->get_matching_coords( sub ($v) { $v =~ /[v^<>]/ } );

    return visit_internal( \@table, $start_row, $start_col, $mountaineer, $initial, $rowcount,
        $colcount );
}

sub saypos ( $row, $col, $dir ) {
    say join( ",", $row + 1, $col + 1, $dir );
    return;
}

my $lastone;

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

    my @out;
    my @queue;
    push @queue, [ $start, 0, { $start => 1 } ];
    while ( scalar(@queue) ) {
        my $top = shift(@queue);
        my ( $node, $cnt, $visited ) = $top->@*;
        $visited->{$node} = 1;

        for my $next ( $graph{$node}->@* ) {
            my ( $nextnode, $nextcnt ) = @$next;
            if ( exists $visited->{$nextnode} ) {
                next;
            }

            if ( $nextnode eq $end ) {
                push @out, $nextcnt + $cnt;
                next;
            }

            my (%newvisited) = %$visited;
            push @queue, [ $nextnode, $nextcnt + $cnt, \%newvisited ];
        }
    }

    return max @out;
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

sub visit_internal ( $table, $start_row, $start_col, $mountaineer, $initial, $rowcount, $colcount )
{
    my @queue;
    my @ends;

    push @queue, [ $table, $start_row, $start_col, $initial ];
    my (@blocks) = @$table;

    while ( scalar(@queue) ) {
        my $top = shift(@queue);
        my ( $torig, $row, $col, $cnt ) = $top->@*;
        my @tnew = @$torig;
        my $t    = \@tnew;

      REPEAT:

        $t->[ $row * $colcount + $col ] = '*';
        $cnt++;

        # Where can I go?
        if ( $row == $rowcount - 1 ) {
            push @ends, $cnt;
            next;
        }

        my @next;
        if ( !$mountaineer ) {
            if ( $row >= 1 ) {    # We can go north
                push @next, [ $row - 1, $col, qr/[.^U]/ ];
            }
            if ( $col >= 2 ) {    # We can go west
                push @next, [ $row, $col - 1, qr/[.<L]/ ];
            }
            if ( $col < $colcount - 1 ) {    # We can go east
                push @next, [ $row, $col + 1, qr/[.>R]/ ];
            }
            push @next, [ $row + 1, $col, qr/[.vD]/ ];    # We can go south always
        } else {
            if ( $row >= 1 ) {                            # We can go north
                push @next, [ $row - 1, $col, qr/[.^>v<U]/ ];
            }
            if ( $col >= 2 ) {                            # We can go west
                push @next, [ $row, $col - 1, qr/[.^>v<L]/ ];
            }
            if ( $col < $colcount - 1 ) {                 # We can go east
                push @next, [ $row, $col + 1, qr/[.^>v<R]/ ];
            }
            push @next, [ $row + 1, $col, qr/[.^>v<D]/ ];    # We can go south always
        }

        for my $n (@next) {
            my $r = $n->[0];
            my $c = $n->[1];
            if ( $r * $colcount + $c > scalar(@$t) ) {
                die();
            }
        }

        my @valid = grep { $t->[ $_->[0] * $colcount + $_->[1] ] =~ $_->[2] } @next;

        if ( scalar(@valid) == 0 ) {
            next;
        }

        if ( scalar(@valid) == 1 ) {
            my $v = $valid[0];
            $row = $v->[0];
            $col = $v->[1];
            goto REPEAT;
        }

        for my $v (@valid) {
            push @queue, [ $t, $v->[0], $v->[1], $cnt ];
        }
    }
    return max(@ends);
}
