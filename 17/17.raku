#!/usr/bin/env raku
use v6.d;

#
# Copyright © 2023 Joelle Maslak
# All Rights Reserved - See License
#

use AOC::Coord;
use AOC::Table;

# constant $MAX-COST = 2⁶⁴ - 1;
constant $MAX-COST = 999;

enum Direction <H V>;

class Edge {
    has Coord:D $.coord is required;
    has UInt:D  $.cost  is required;

    method gist(--> Str:D) { self.Str }
    method Str(--> Str:D) { sprintf "%s [%d]", $!coord, $!cost; }
}

class Edges {
    has Edge:D @.h is default($MAX-COST);
    has Edge:D @.v is default($MAX-COST);

    method gist(--> Str:D) { self.Str }
    method Str(--> Str:D) { sprintf "H: (%s), V: (%s)", @!h.join(";"), @!v.join(";") }
}

class Costs {
    has UInt:D $.h is rw = $MAX-COST;
    has UInt:D $.v is rw = $MAX-COST;
    
    method gist(--> Str:D) { self.Str }
    method Str(--> Str:D) { sprintf "%4d/%3d", $!h, $!v }
}

sub MAIN() {
    my $t = Table.new(:type(Int:D), :format("%2d"), :default(0));
    $t.read();

    say "Heat loss part A: ", find-min-cost($t, 1, 3);
    say "Heat loss part B: ", find-min-cost($t, 4, 10);
}

sub find-min-cost(Table:D $t, UInt:D() $min-dist, UInt:D() $max-dist -->UInt:D) {
    my $edges = Table.new(:type(Edges:D), :default(Edges.new()));
    update-edges($t, $edges, $min-dist, $max-dist);
    
    my $costs = Table.new(:type(Costs:D), :default(Costs.new()));
    update-costs($edges, $costs);

    my $node-costs = $costs.get($costs.max-coord);
    my $min = min $node-costs.h, $node-costs.v;
    return $min;
}

sub update-edges(Table:D $t, Table:D $dist, UInt:D() $min-dist, UInt:D() $max-dist -->Nil) {
    my $maxi = $t.row-count;
    my $maxj = $t.col-count;

    for $t.rows.kv.reverse -> $rowval, $i {  # Reverse for performance
        for $rowval.keys.reverse -> $j {
            my $edges = Edges.new();

            # Vertical edges
            my $sum-up = 0;
            my $sum-dn = 0;
            for 1..$max-dist -> $di {
                if $i + $di < $maxi {
                    $sum-up += $t.get($i + $di, $j);
                    my $c = Coord.new(:row($i + $di), :col($j));
                    $edges.v.push(Edge.new(:coord($c), :cost($sum-up))) unless $di < $min-dist;
                }
                if $i - $di ≥ 0 {
                    $sum-dn += $t.get($i - $di, $j);
                    my $c = Coord.new(:row($i - $di), :col($j));
                    $edges.v.push(Edge.new(:coord($c), :cost($sum-dn))) unless $di < $min-dist;
                }
            }

            # Horizontal edges
            $sum-up = 0;
            $sum-dn = 0;
            for 1..$max-dist -> $dj {
                if $j + $dj < $maxj {
                    $sum-up += $t.get($i, $j + $dj);
                    my $c = Coord.new(:row($i), :col($j + $dj));
                    $edges.h.push(Edge.new(:coord($c), :cost($sum-up))) unless $dj < $min-dist;
                }
                if $j - $dj ≥ 0 {
                    $sum-dn += $t.get($i, $j - $dj);
                    my $c = Coord.new(:row($i), :col($j - $dj));
                    $edges.h.push(Edge.new(:coord($c), :cost($sum-dn))) unless $dj < $min-dist;
                }
            }

            # Write out to table
            $dist.put($i, $j, $edges);
        }
    }

    return;
}

sub update-costs(Table:D $edges, Table:D $costs -->Nil) {
    # Shape / populte the cost table
    my $zero = Costs.new(:h($MAX-COST), :v($MAX-COST));
    $costs.put($edges.row-count - 1, $edges.col-count - 1, $zero);

    class Stack {
        has Coord:D     $.coord is required,
        has Direction:D $.dir   is required,
        has UInt:D      $.cost  is required,
    }

    my Stack @stack;
    @stack.push: Stack.new(:coord(Coord.new(:0row, :0col)), :dir(H), :0cost);
    @stack.push: Stack.new(:coord(Coord.new(:0row, :0col)), :dir(V), :0cost);
    while my $top = @stack.shift {

        # Update cost of current node
        my $me = $costs.get($top.coord);
        if $top.dir == H and $top.cost < $me.h {
            $me.h = $top.cost;
        } elsif $top.dir == V and $top.cost < $me.v {
            $me.v = $top.cost;
        } else {
            next;  # Not cheaper!
        }

        if $top.dir == V {
            my @visit = $edges.get($top.coord).h;
            @stack.push: @visit.map({ Stack.new(:coord($^e.coord), :dir(H), :cost($^e.cost + $top.cost)) }).Slip;
        } elsif $top.dir == H {
            my @visit = $edges.get($top.coord).v;
            @stack.push: @visit.map({ Stack.new(:coord($^e.coord), :dir(V), :cost($^e.cost + $top.cost)) }).Slip;
        }
    }
    return;
}

