#!/usr/bin/perl

#
# Copyright (C) 2024 Joelle Maslak
# All Rights Reserved - See License
#

use JTM::Boilerplate 'script';
use List::Util qw(any max min zip);
use lib '.';
use Table;
use Data::Dumper;

MAIN: {
    my $table = Table->new();
    $table->read(\*STDIN);
    my @moves;
    while (my $line = <STDIN>) {
        chomp($line);
        push @moves, split //, $line;
    }
    my $orig = $table->copy();

    my (@positions) = $table->find('@');
    my $pos = $positions[0];

    if (scalar($table->find('['))) {
        goto FOO;
    }

    for my $move (@moves) {
        $table->put($pos, '.');
        my $row = $pos->row();
        my $col = $pos->col();
        if (($move eq '>') or ($move eq '<')) {
            # Horizontal
            my (@row) = $table->get_row($row);

            my $dir = 1;
            if ($move eq '<') {
                $dir = -1;
            }

            if ($row[$col+$dir] eq '.') {
                $pos = Coord->new(row => $row, col => $col+$dir);
            } elsif ($row[$col+$dir] eq '#') {
                # Do nothing.
            } else {
                my $newbox = $col;
                my $newpos = $col;
                while ($row[$newbox+$dir] ne '#') {
                    if ($row[$newbox+$dir] eq '.') {
                        $table->put_xy($row, $newbox+$dir, 'O');
                        $newpos = $newpos + $dir;
                        last;
                    }
                    $newbox = $newbox + $dir;
                }
                $pos = Coord->new(row => $row, col => $newpos);
            }
            $table->put($pos, '@');
        } else {
            # Vertical
            my (@col) = $table->get_col($col);

            my $dir = 1;
            if ($move eq '^') {
                $dir = -1;
            }

            if ($col[$row+$dir] eq '.') {
                $pos = Coord->new(row => $row+$dir, col => $col);
            } elsif ($col[$row+$dir] eq '#') {
                # Do nothing.
            } else {
                my $newbox = $row;
                my $newpos = $row;
                while ($col[$newbox+$dir] ne '#') {
                    if ($col[$newbox+$dir] eq '.') {
                        $table->put_xy($newbox+$dir, $col, 'O');
                        $newpos = $newpos + $dir;
                        last;
                    }
                    $newbox = $newbox + $dir;
                }
                $pos = Coord->new(row => $newpos, col => $col);
            }
            $table->put($pos, '@');
        }
    }

FOO:
    my (@boxes) = $table->find('O');
    my $part1 = 0;
    for my $box (@boxes) {
        $part1 += 100 * $box->row + $box->col;
    }

    say "Part 1: $part1";

    if (@boxes) {
        $table = widen($orig);
    } else {
        $table = $orig;
    }
    @positions = $table->find('@');
    $pos = $positions[0];

    for my $move (@moves) {
        $table->put($pos, '.');
        my $row = $pos->row();
        my $col = $pos->col();
        if (($move eq '>') or ($move eq '<')) {
            # Horizontal
            my (@row) = $table->get_row($row);

            my $dir = 1;
            if ($move eq '<') {
                $dir = -1;
            }

            if ($row[$col+$dir] eq '.') {
                $pos = Coord->new(row => $row, col => $col+$dir);
            } elsif ($row[$col+$dir] eq '#') {
                # Do nothing.
            } else {
                my $newbox = $col;
                my $newpos = $col;
                while ($row[$newbox+$dir] ne '#') {
                    if ($row[$newbox+$dir] eq '.') {
                        my $min = min ($newbox+$dir, $col+$dir+$dir);
                        my $max = max ($newbox+$dir, $col+$dir+$dir);
                        my $state = '[';
                        for (my $i=$min; $i<=$max; $i++) {
                            $table->put_xy($row, $i, $state);
                            $state = $state eq '[' ? ']' : '[';
                        }

                        $newpos = $newpos + $dir;
                        last;
                    }
                    $newbox = $newbox + $dir;
                }
                $pos = Coord->new(row => $row, col => $newpos);
            }
            $table->put($pos, '@');
        } else {
            # Vertical
            my (@col) = $table->get_col($col);

            my $dir = 1;
            if ($move eq '^') {
                $dir = -1;
            }

            if ($col[$row+$dir] eq '.') {
                $pos = Coord->new(row => $row+$dir, col => $col);
            } elsif ($col[$row+$dir] eq '#') {
                # Do nothing.
            } else {
                my $possible = do_shift($table, $row+$dir, $dir, $col);
                if (defined($possible)) {
                    $table = $possible;
                    $pos = Coord->new(row => $row+$dir, col => $col);
                }
            }
            $table->put($pos, '@');
        }
    }
    
    @boxes = $table->find('[');
    my $part2 = 0;
    for my $box (@boxes) {
        $part2 += 100 * $box->row + $box->col;
    }

    say "Part 2: $part2";
}

sub shift_up($t, $row, @cols) {
    return $t;
}

sub do_shift($t, $row, $dir, @cols) {
    my %c;
    if ($t->get_xy($row, $cols[0]) eq ']') {
        unshift @cols, $cols[0] - 1;
    }
    if ($t->get_xy($row, $cols[-1]) eq '[') {
        unshift @cols, $cols[0] + 1;
    }

    my %newcols;
    my $need_recurse = 0;
    for my $col (@cols) {
        my $my_val = $t->get_xy($row, $col);
        if ($my_val ne '.') {
            $newcols{$col} = 1;
        }
        if ($t->get_xy($row+$dir, $col) eq '.') {
            # We can always do this shift.
        } else {
            my $down_val = $t->get_xy($row+$dir, $col);
            if ($my_val eq '.') {
                # Do nothing
            } elsif ($down_val eq '#') {
                # We can't do this shift.
                return undef;
            } elsif ($down_val eq ']') {
                $newcols{$col-1} = 1;
                $need_recurse = 1;
            } elsif ($down_val eq '[') {
                $newcols{$col+1} = 1;
                $need_recurse = 1;
            }
        }
    }

    if ($need_recurse) {
        $t = do_shift($t, $row+$dir, $dir, sort { $a <=> $b } keys %newcols);
    }
    if (!defined($t)) { return undef; }

    for my $col (@cols) {
        my $oldval = $t->get_xy($row, $col);
        my $newval = $t->get_xy($row+$dir, $col);

        if ($newval eq '#') {
            # do nothing
        } else {
            if ($oldval ne '.' and $oldval ne '#') {
                $t->put_xy($row+$dir, $col, $oldval);
            }
            if ($oldval ne '#') {
                $t->put_xy($row, $col, '.');
            }
        }
    }

    return $t;
}

sub widen($table) {
    my $rows = $table->row_count();
    my $cols = $table->col_count();

    my $newtable = Table->new();

    for (my $row = 0; $row<$rows; $row++) {
        for (my $col = 0; $col<$cols; $col++) {
            my $value = $table->get_xy($row, $col);
            if ($value eq '#') {
                $newtable->put_xy($row, $col*2,   '#');
                $newtable->put_xy($row, $col*2+1, '#');
            } elsif ($value eq '@') {
                $newtable->put_xy($row, $col*2,   '@');
                $newtable->put_xy($row, $col*2+1, '.');
            } elsif ($value eq '.') {
                $newtable->put_xy($row, $col*2,   '.');
                $newtable->put_xy($row, $col*2+1, '.');
            } elsif ($value eq 'O') {
                $newtable->put_xy($row, $col*2,   '[');
                $newtable->put_xy($row, $col*2+1, ']');
            }
        }
    }

    return $newtable;
}
