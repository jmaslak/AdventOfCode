#!/usr/bin/perl

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';

use List::Util qw(any sum);

use Data::Dump;

MAIN: {
    my %graph;
    my @conns;
    while ( my $line = <<>> ) {
        chomp $line;
        my ( $src, @dst ) = split /:?\s+/, $line;
        for my $d (@dst) {
            if ( !exists( $graph{$src} ) ) { $graph{$src} = [] }
            if ( !exists( $graph{$d} ) )   { $graph{$d}   = [] }
            push $graph{$src}->@*, $d;
            push $graph{$d}->@*,   $src;
            push @conns,           conn( $src, $d );
        }
    }

    my (@nodes) = keys %graph;

    my $st = 0;
    my $en = $st + 1;

    my $start = $nodes[$st];
    my $end   = $nodes[$en];

    say "$start ($st)   $end ($en)";

    my @fail;
  FIND:
    while (1) {
        my $path1 = path( \%graph, $start, $end );
        for my $a (@$path1) {
            my $path2 = path( \%graph, $start, $end, $a );
            for my $b (@$path2) {
                my $path3 = path( \%graph, $start, $end, $a, $b );
                for my $c (@$path3) {
                    my $path4 = path( \%graph, $start, $end, $a, $b, $c );
                    if ( !$path4 ) {
                        @fail = ( $a, $b, $c );
                        last FIND;
                    }
                }
            }
        }
        $en++;
        say "$en";
        $end = $nodes[$en];
    }

    say "FOUND!";

    my $ret = isolated( \%graph, $start, @fail );

    say "Part A: $ret";
}

sub path ( $graph, $src, $dst, @ignores ) {
    my @nodes = keys %$graph;

    my @stack;
    push @stack, [ $src, [] ];
    my %marks;
    while ( scalar(@stack) ) {
        my ( $head, $path ) = ( shift(@stack)->@* );
        if ( $head eq $dst )        { return $path }
        if ( exists $marks{$head} ) { next; }

        $marks{$head} = 1;

        for my $next ( $graph->{$head}->@* ) {
            if ( any { conn( $head, $next ) eq $_ } @ignores ) {
                next;
            }
            if ( exists $marks{$next} ) { next; }
            push @stack, [ $next, [ @$path, conn( $head, $next ) ] ];

        }
    }
    return undef;
}

sub isolated ( $graph, $start, @fails ) {
    my @nodes = keys %$graph;

    my @stack;
    push @stack, $nodes[0];
    my %marks;
    while ( scalar(@stack) ) {
        my $head = shift @stack;
        if ( exists $marks{$head} ) { next; }

        $marks{$head} = 1;

        for my $next ( $graph->{$head}->@* ) {
            if ( any { conn( $head, $next ) eq $_ } @fails ) {
                next;
            }
            if ( exists $marks{$next} ) { next; }
            push @stack, $next;
        }
    }

    my $group1 = sum values %marks;
    my $group2 = scalar(@nodes) - $group1;

    if ( $group2 > 1 and $group1 > 1 ) {
        return ( $group1 * $group2 );
    }
    return undef;
}

sub conn (@c) { return join ':', sort @c }

sub connparts ($c) { return split( ':', $c ) }

