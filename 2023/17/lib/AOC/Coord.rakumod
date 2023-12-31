use v6;

#
# Copyright © 2023 Joelle Maslak
# All Rights Reserved - See License
#

unit class AOC::Coord:ver<0.0.1> is export;

# We allow negative values because sometimes they are handy.
has Int:D $.row is required;
has Int:D $.col is required;

method n() { AOC::Coord.new(row => $!row - 1, col => $!col) }
method s() { AOC::Coord.new(row => $!row + 1, col => $!col) }
method w() { AOC::Coord.new(row => $!row, col => $!col + 1) }
method e() { AOC::Coord.new(row => $!row, col => $!col - 1) }

method gist() { return self.Str; }
method Str(--> Str:D) { "$!row,$!col" }

use MONKEY-TYPING;
augment class Str {
    method AOC::Coord {
        my $match = self ~~ /^ ("-"? <[0..9]>+) \,\s* ("-"? <[0..9]>+) $/;
        return AOC::Coord.new(row => $match[0].Int, col => $match[1].Int);
    }
}
