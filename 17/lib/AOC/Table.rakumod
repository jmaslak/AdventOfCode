use v6;

#
# Copyright © 2023 Joelle Maslak
# All Rights Reserved - See License
#

use AOC::Coord;

unit class AOC::Table:ver<0.0.1> is export;

has Any:U $.type is default(Str:D);
has Any   $.default is default(".");
has Str:D $.format is default("%s") is rw;

has Int:D $.row-count is readonly = 0;
has Int:D $.col-count is readonly = 0;

has $!rows;

submethod TWEAK() {
    $!rows = Array[Array[$!type]].new();
}

multi method put(AOC::Coord:D $c, $v --> Nil) { self.put($c.row, $c.col, $v) }
multi method put(Int:D() $row, Int:D() $col, $v --> Nil) {
    die "Cannot access negative elements" if $row|$col < 0;
    if ($row ≥ $!row-count) {
        for $!row-count..$row -> $i {
            $!rows[$i] = Array[$!type].new(map { $^a.clone }, $.default xx $!col-count);
        }
        $!row-count = $row + 1;
    }
    if ($col ≥ $!col-count) {
        for 0..($!row-count - 1) -> $i {
            push $!rows[$i],  (map { $^a.clone }, $!default xx ($col + 1 - $!col-count)).Slip;
        }
        $!col-count = $col + 1;
    }

    $!rows[$row; $col] = $!type($v);
    return;
}

method put-row(Int:D $row, @v --> Nil) {
    for @v.kv.reverse -> $v, $col {  # Reversed so we get a performance boost
        self.put($row, $col, $v);
    }
}

method put-col(Int:D $col, @v --> Nil) {
    for @v.kv.reverse -> $v, $row {  # Reversed so we get a performance boost
        self.put($row, $col, $v);
    }
}

method rows(--> Seq) {
    return map { $^a.clone }, $!rows<>;
}

method cols(--> Array[Array[]]) {
    my $t = self.clone-swap-axis();
    return $t.$!rows<>;
}

method row(Int:D $row --> Seq) {
    die "Cannot access negative elements" if $row < 0;
    die "Cannot access out of bound row"  if $row ≥ $!row-count;
    return map { $^a }, $!rows[$row].Slip
}

method col(Int:D $col --> Seq) {
    die "Cannot access negative elements"   if $col < 0;
    die "Cannot access out of bound column" if $col ≥ $!col-count;
    return map { $!rows[$^row; $col] }, 0..^$!row-count;
}

multi method get(AOC::Coord:D $c --> Any) { self.get($c.row, $c.col) }
multi method get(Int:D $row, Int:D $col --> Any) {
    die "Cannot access negative elements"   if $row|$col < 0;
    die "Cannot access out of bound row"    if $row ≥ $!row-count;
    die "Cannot access out of bound column" if $col ≥ $!col-count;

    return $!rows[$row; $col];
}

method get-matching-coords($sub --> Seq) {
    return gather {
        for $!rows.kv -> $row, $rowval {
            for $rowval.kv -> $col, $v {
                take AOC::Coord.new(row => $row, col => $col) if $sub($v);
            }
        }
    }
}

method put-col-before(Int:D $col, @v --> Nil) {
    my @newcol = @v;
    if @newcol.elems < $!row-count {
        push @newcol, (map { $^a.clone }, $!default xx ($!row-count - @newcol.elems)).Slip;
    }

    if $col ≥ $!col-count {
        self.put-col($col, @v);
        return;
    }

    for $!rows.kv -> $i, $row {
        my @start = $col ?? $row[0..^$col] !! ();
        my @end   = $row[$col..(*-1)];
        $!rows[$i] = Array[$!type].new: @start.Slip, @newcol[$i], @end.Slip;
    }

    $!col-count++;
    return;
}

method put-row-before(Int:D $row, @v --> Nil) {
    my $newrow = Array[$!type].new(@v);
    if $newrow.elems < $!col-count {
        push $newrow, (map { $^a.clone }, $!default xx ($!col-count - $newrow.elems)).Slip;
    }

    if $row ≥ $!row-count {
        self.put-row($row, @v);
        return;
    }

    my $out = Array[Array[$!type]].new();
    my @start = $row ?? $!rows[0..^$row] !! ();
    my @end   = $!rows[$row..(*-1)];

    $out.push: @start.Slip;
    $out.push: $newrow<>;
    $out.push: @end.Slip;

    $!rows = $out;
    $!row-count++;

    return;
}

method add-border($v = $!default --> Nil) {
    self.put-col($!col-count, map({ $^a.clone }, $v xx $!row-count));
    self.put-row($!row-count, map({ $^a.clone }, $v xx $!col-count));
    self.put-col-before(0, map({ $^a.clone }, $v xx $!row-count));
    self.put-row-before(0, map({ $^a.clone }, $v xx $!col-count));
    return;
}

method clone(Bool :$clone --> AOC::Table:D) {
    # Reversed for performance reasons
    my AOC::Table:D $t = AOC::Table.new(:type($!type), :format($!format), :default($!default));
    for $!rows.kv.reverse -> $rowval, $row {
        for $rowval.kv.reverse -> $ele, $col {
            if $clone {
                $t.put($row, $col, $ele.clone);
            } else {
                $t.put($row, $col, $ele);
            }
        }
    }
    return $t;
}

method clone-swap-axis(Bool :$clone --> AOC::Table:D) {
    # Reversed for performance reasons
    my AOC::Table:D $t = AOC::Table.new(:type($!type), :format($!format), :default($!default));
    for $!rows.kv.reverse -> $rowval, $row {
        for $rowval.kv.reverse -> $ele, $col {
            if $clone {
                $t.put($col, $row, $ele.clone);
            } else {
                $t.put($col, $row, $ele);
            }
        }
    }
    return $t;
}

method read(IO::Handle:D() :$in = $*IN, Sub:D() :$code = sub { $^a.split("", :skip-empty) }, Str :$stop -->Nil) {
    for $in.lines() -> $line {
        return if $stop.defined and $line eq $stop;
        self.put-row($!row-count, $code($line));
    }
    return;
}

method max-coord(-->Coord:D) { Coord.new(:row($!row-count - 1), :col($!col-count - 1)) }

method gist(--> Str:D) { self.Str() }
method Str(--> Str:D) {
    my @lines;
    for $!rows<> -> $row {
        push @lines, join "", map { sprintf($!format, $^a) }, $row.Slip;
    }
    return @lines.join("\n");
}
