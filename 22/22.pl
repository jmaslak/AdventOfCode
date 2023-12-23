#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use List::Util qw(min all uniqnum);

MAIN: {
    my %space;
    my @bricks;
    my $id = 0;
    while ( my $line = <<>> ) {
        chomp($line);
        my ( $x1, $y1, $z1, $x2, $y2, $z2 ) = split /[,~]/, $line;

        ( $x1, $x2 ) = sort { $a <=> $b } $x1, $x2;
        ( $y1, $y2 ) = sort { $a <=> $b } $y1, $y2;
        ( $z1, $z2 ) = sort { $a <=> $b } $z1, $z2;

        $bricks[$id] = {};
        for ( my $x = $x1; $x <= $x2; $x++ ) {
            for ( my $y = $y1; $y <= $y2; $y++ ) {
                for ( my $z = $z2; $z >= $z1; $z-- ) {
                    my $xy = "$x,$y";
                    $bricks[$id]->{$xy} = $z;
                    if ( !exists $space{$xy} ) { $space{$xy} = [] }
                    push $space{$xy}->@*, [ $z, $id ];
                }
            }
        }

        $id++;
    }
    my @under;
    my @over;
    for my $id ( 0 .. $#bricks ) {
        $under[$id] = {};
        for my $xy ( keys $bricks[$id]->%* ) {
            my (@zs) = grep { $_->[1] == $id } $space{$xy}->@*;
            my $z = $zs[0]->[0];

            for my $v ( $space{$xy}->@* ) {
                my $testz  = $v->[0];
                my $testid = $v->[1];

                if ( $testid == $id ) {
                    # do nothing
                } elsif ( $testz < $z ) {
                    # Testid is under me.
                    if ( !defined( $over[$testid] ) ) { $over[$testid] = {} }
                    $over[$testid]->{$id}  = $z;
                    $under[$id]->{$testid} = $z;
                }
            }
        }
    }

    # Tetris...
    my (@queue) = grep { scalar( keys $under[$_]->%* ) == 0 } 0 .. $#under;
    while ( scalar(@queue) ) {
        my $head = shift(@queue);

        my $lowest = 0;
        my $me_min = 2**32;
        for my $xy ( keys $bricks[$head]->%* ) {
            for my $ele ( $space{$xy}->@* ) {
                my $underid = $ele->[1];
                my $underz  = $ele->[0];

                if ( $underid == $head ) {
                    if ( $me_min > $underz ) { $me_min = $underz }
                } else {
                    if ( exists( $under[$head]->{$underid} ) ) {
                        if ( $lowest < $underz ) { $lowest = $underz }
                    }
                }
            }
        }
        $lowest++;

        # Lower me.
        for my $xy ( keys $bricks[$head]->%* ) {
            for my $ele ( $space{$xy}->@* ) {
                my $underid = $ele->[1];

                if ( $underid == $head ) {
                    $ele->[0] = $ele->[0] - $me_min + $lowest;
                }
            }
        }

        push @queue, keys $over[$head]->%*;
        @queue = uniqnum @queue;
    }

    my (@directunder) = map { [] } 0 .. ($#bricks);
    my (@directover)  = map { [] } 0 .. ($#bricks);
    my $previd        = undef;
    my $prevheight;
    for my $xy ( keys %space ) {
        my (@spacev) = sort { $a->[0] <=> $b->[0] } $space{$xy}->@*;
        my $pointer;

        for my $ele (@spacev) {
            my $z  = $ele->[0];
            my $id = $ele->[1];
            if ( !defined($prevheight) ) {
                # Do nothing;
            } elsif ( $id == $previd ) {
                # Do nothing;
            } elsif ( $prevheight + 1 == $z ) {
                push $directunder[$id]->@*,    $previd;
                push $directover[$previd]->@*, $id;

                $directunder[$id]->@*    = uniqnum $directunder[$id]->@*;
                $directover[$previd]->@* = uniqnum $directover[$previd]->@*;
            }
            $prevheight = $z;
            $previd     = $id;
        }
    }

    my @removable;
    for my $id ( 0 .. $#bricks ) {
        if ( scalar( $directover[$id]->@* ) == 0 ) {
            push @removable, $id;
            next;
        }
        if ( all { scalar( $directunder[$_]->@* ) > 1 } $directover[$id]->@* ) {
            push @removable, $id;
            next;
        } else {
            # Do nothing
        }
    }
    say "How many dominos can be individually removed without impacting others? "
      . scalar(@removable);

    my (@countunder) = map { scalar( $directunder[$_]->@* ) } 0 .. $#bricks;
    my (@countover)  = map { scalar( $directover[$_]->@* ) } 0 .. $#bricks;
    my (@lowest)     = map { min values $bricks[$_]->%* } 0 .. $#bricks;

    # Find depndencies

    my $sum = 0;
    for my $start ( 0 .. $#bricks ) {
        my %marked;
        push @queue, $start;
        while ( scalar(@queue) ) {
            my $head = shift @queue;
            if ( $head == $start ) {
                # We do not count this brick.
                $marked{$head} = 1;
                push @queue, $directover[$head]->@*;
            } else {
                if ( all { exists $marked{$_} } $directunder[$head]->@* ) {
                    $sum++;
                    $marked{$head} = 1;
                    push @queue, $directover[$head]->@*;
                }
            }

            @queue = sort { $lowest[$a] <=> $lowest[$b] } uniqnum @queue;
        }
    }
    say "Total of dependent-falling bricks: $sum";
}

