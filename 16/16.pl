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
use Parallel::WorkUnit;
use Sys::Info;

my (%directions) = (
    L => 1,
    R => 2,
    U => 4,
    D => 8
);

MAIN: {
    my $t = Table->new();
    $t->read( *ARGV, sub { split // } );
    my $marked = Table->new();

    my $start = [ 0, -1 ];
    my $dir   = "R";

    mark_energized( $t, $marked, $start, $dir );
    my $res = count_marked($marked);
    say("Result part A: $res");

    my $wu  = Parallel::WorkUnit->new();
    my $cpu = Sys::Info->new()->device( CPU => {} );
    $wu->max_children( $cpu->count() );

    my @results;
    my $callback = sub ($x) { push @results, $x };
    my $sub      = sub ( $start, $dir ) {
        my $marked = Table->new();
        mark_energized( $t, $marked, $start, $dir );
        return count_marked($marked);
    };

    for ( my $row = 0; $row < $t->row_count(); $row++ ) {
        $wu->queue( sub { $sub->( [ $row, -1 ], 'R' ) }, $callback );
        $wu->queue( sub { $sub->( [ $row, $t->col_count() ], 'L' ) }, $callback );
    }

    for ( my $col = 0; $col < $t->col_count(); $col++ ) {
        $wu->queue( sub { $sub->( [ -1, $col ], 'D' ) }, $callback );
        $wu->queue( sub { $sub->( [ $t->row_count(), $col ], 'U' ) }, $callback );
    }
    $wu->waitall();
    my $max = max @results;
    say("Result part B: $max");
}

sub mark_energized ( $src, $marked, $start, $dir ) {
    my @next;
    if ( $dir eq 'L' ) {
        (@next) = ( $start->[0], $start->[1] - 1 );
    } elsif ( $dir eq 'R' ) {
        (@next) = ( $start->[0], $start->[1] + 1 );
    } elsif ( $dir eq 'U' ) {
        (@next) = ( $start->[0] - 1, $start->[1] );
    } elsif ( $dir eq 'D' ) {
        (@next) = ( $start->[0] + 1, $start->[1] );
    }
    if ( $next[0] < 0 )                  { return; }
    if ( $next[1] < 0 )                  { return; }
    if ( $next[0] >= $src->row_count() ) { return; }
    if ( $next[1] >= $src->col_count() ) { return; }

    my $dirval = $directions{$dir};
    if ( !defined($dirval) ) { die; }
    my $mark = $marked->get_xy(@next);
    if ( ( $mark // 0 ) & $dirval ) {
        return;
    }
    $marked->put_xy( $next[0], $next[1], ( $mark // 0 ) | $dirval );

    my $new_cell = $src->get_xy( $next[0], $next[1] );
    if ( $new_cell eq '.' ) {
        (@_) = ( $src, $marked, \@next, $dir );
        goto &mark_energized;
    } elsif ( $new_cell eq '-' ) {
        if ( ( $dir eq 'L' ) or ( $dir eq 'R' ) ) {
            @_ = ( $src, $marked, \@next, $dir );
            goto &mark_energized;
        } else {
            mark_energized( $src, $marked, \@next, 'L' );
            mark_energized( $src, $marked, \@next, 'R' );
        }
    } elsif ( $new_cell eq '|' ) {
        if ( ( $dir eq 'U' ) or ( $dir eq 'D' ) ) {
            @_ = ( $src, $marked, \@next, $dir );
            goto &mark_energized;
        } else {
            mark_energized( $src, $marked, \@next, 'U' );
            mark_energized( $src, $marked, \@next, 'D' );
        }
    } elsif ( $new_cell eq '/' ) {
        if ( $dir eq 'L' ) {
            mark_energized( $src, $marked, \@next, 'D' );
        } elsif ( $dir eq 'R' ) {
            mark_energized( $src, $marked, \@next, 'U' );
        } elsif ( $dir eq 'U' ) {
            mark_energized( $src, $marked, \@next, 'R' );
        } elsif ( $dir eq 'D' ) {
            mark_energized( $src, $marked, \@next, 'L' );
        }
    } elsif ( $new_cell eq '\\' ) {
        if ( $dir eq 'L' ) {
            mark_energized( $src, $marked, \@next, 'U' );
        } elsif ( $dir eq 'R' ) {
            mark_energized( $src, $marked, \@next, 'D' );
        } elsif ( $dir eq 'U' ) {
            mark_energized( $src, $marked, \@next, 'L' );
        } elsif ( $dir eq 'D' ) {
            mark_energized( $src, $marked, \@next, 'R' );
        }
    }
    return;
}

sub count_marked ($marked) {
    my (@matches) = $marked->get_matching_coords( sub ($x) { return $x // 0 } );
    return scalar(@matches);
}
