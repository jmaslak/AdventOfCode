#!/usr/bin/env perl

#
# Copyright (C) 2025 Joelle Maslak
# All Rights Reserved - See License
#

use lib '.';

use JTM::Boilerplate 'script';
use List::Util qw(min max);
use Table;

sub size( $a, $b ) { return abs( ( $a->row - $b->row ) * ( $a->col - $b->col ) ) }

# Part 1 is straightforward.
# Part 2 is a bit more complex!  The input data gave me a hint though.
#        No parallel lines were neighbors (I.E. two horizontal lines on
#        neighboring rows).  With this being safe, and also no
#        overlapping shapes, this could be simplified.  For each
#        candidate rectangle, I built an "inner" rectangle one square
#        inside of each of the sides, and made sure that those four
#        lines did not cross any other lines.  If overlapping lines
#        existed, or neighboring parallel lines existed, this would have
#        been a problem.

class Line {
    field $c1 : param;
    field $c2 : param;

    method c1() { $c1 }
    method c2() { $c2 }

    method top()    { List::Util::min( $c1->row, $c2->row ) }
    method bottom() { List::Util::max( $c1->row, $c2->row ) }
    method left()   { List::Util::min( $c1->col, $c2->col ) }
    method right()  { List::Util::max( $c1->col, $c2->col ) }

    method cross($l) {
        if ( $self->top == $self->bottom ) {
            # self is horizontal, l vertical
            # Exit if l is horizontal.
            if ( $l->top == $l->bottom ) { return }
        } else {
            # self is vertical, l horizontal
            # Exit if l is vertical.
            if ( $l->left == $l->right ) { return }
        }

        if ( $l->top > $self->bottom ) { return }
        if ( $l->bottom < $self->top ) { return }
        if ( $l->right < $self->left ) { return }
        if ( $l->left > $self->right ) { return }

        return 1;
    }
}

class Rectangle {
    field $c1 : param;
    field $c2 : param;

    method c1() { $c1 }
    method c2() { $c2 }

    method size() { ( 1 + abs( $c1->row - $c2->row ) ) * ( 1 + abs( $c1->col - $c2->col ) ) }

    method inside_lines() {
        my $tl = Coord->new(
            row => List::Util::min( $c1->row, $c2->row ) + 1,
            col => List::Util::min( $c1->col, $c2->col ) + 1
        );
        my $tr = Coord->new(
            row => List::Util::min( $c1->row, $c2->row ) + 1,
            col => List::Util::max( $c1->col, $c2->col ) - 1
        );
        my $bl = Coord->new(
            row => List::Util::max( $c1->row, $c2->row ) - 1,
            col => List::Util::min( $c1->col, $c2->col ) + 1
        );
        my $br = Coord->new(
            row => List::Util::max( $c1->row, $c2->row ) - 1,
            col => List::Util::max( $c1->col, $c2->col ) - 1
        );

        return (
            Line->new( c1 => $tl, c2 => $tr ),
            Line->new( c1 => $tr, c2 => $br ),
            Line->new( c1 => $br, c2 => $bl ),
            Line->new( c1 => $bl, c2 => $tl ),
        );
    }
}

sub any_cross( $lines1, $lines2 ) {
    for my $line1 (@$lines1) {
        for my $line2 (@$lines2) {
            if ( $line1->cross($line2) ) {
                return 1;
            }
        }
    }
    return;
}

MAIN: {
    my @reds;
    while ( <<>> ) {
        chomp;
        next if $_ eq "";
        my ( $col, $row ) = split /,/;
        push @reds, Coord->new( row => $row, col => $col );
    }

    # Build a list of all the lines connecting points.
    my @lines;
    for my $i ( 1 .. $#reds ) {
        push @lines, Line->new( c1 => $reds[ $i - 1 ], c2 => $reds[$i] );
    }
    push @lines, Line->new( c1 => $reds[-1], c2 => $reds[0] );

    # Solve!
    my $biggest1 = undef;
    my $biggest2 = undef;
    for ( my $i = 0; $i < ( $#reds - 1 ); $i++ ) {
      LOOP: for ( my $j = $i + 1; $j < $#reds; $j++ ) {
            my $r = Rectangle->new( c1 => $reds[$i], c2 => $reds[$j] );
            if ( (!defined($biggest1)) or $biggest1->size < $r->size ) {
                $biggest1 = $r;
            }
            if ( (!defined($biggest2)) or $biggest2->size < $r->size ) {
                # For part 2, we check if the inner square cross any
                # lines.
                if ( !any_cross( \@lines, [ $r->inside_lines ] ) ) {
                    $biggest2 = $r;
                }
            }
        }
    }

    my $part1 = $biggest1->size;
    my $part2 = $biggest2->size;

    say "Part 1: $part1";
    say "Part 2: $part2";
}
