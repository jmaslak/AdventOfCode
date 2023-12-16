package main

import (
	"fmt"
	"os"
)

type Direction int

const (
	L Direction = 1
	R Direction = 2
	U Direction = 4
	D Direction = 8
)

func main() {
	var t Table[rune]
	t.Read(os.Stdin, func(s string) []rune { return []rune(s) })

	start := Coord{row: 0, col: -1}
	dir := R
	var marked Table[Direction]

	markEnergized(t, &marked, start, dir)
	res := countMarked(marked)
	fmt.Printf("Result part A: %d\n", res)

	max := 0
	for row := range t.GetRows() {
		marked.Clear()
		markEnergized(t, &marked, Coord{row: row, col: -1}, R)
		x := countMarked(marked)
		if x > max {
			max = x
		}

		marked.Clear()
		markEnergized(t, &marked, Coord{row: row, col: t.ColCount()}, L)
		x = countMarked(marked)
		if x > max {
			max = x
		}
	}

	for col := range t.GetCols() {
		marked.Clear()
		markEnergized(t, &marked, Coord{row: -1, col: col}, R)
		x := countMarked(marked)
		if x > max {
			max = x
		}

		marked.Clear()
		markEnergized(t, &marked, Coord{row: t.ColCount(), col: col}, R)
		x = countMarked(marked)
		if x > max {
			max = x
		}
	}

	fmt.Printf("Result part B: %d\n", max)

}

func markEnergized(src Table[rune], marked *Table[Direction], start Coord, dir Direction) {
	var next Coord
	if dir == L {
		next = Coord{row: start.Row(), col: start.Col() - 1}
	} else if dir == R {
		next = Coord{row: start.Row(), col: start.Col() + 1}
	} else if dir == U {
		next = Coord{row: start.Row() - 1, col: start.Col()}
	} else if dir == D {
		next = Coord{row: start.Row() + 1, col: start.Col()}
	}

	if next.Row() < 0 || next.Col() < 0 {
		return
	}
	if next.Row() >= src.RowCount() || next.Col() >= src.ColCount() {
		return
	}

	// Have we visited? If we have in this direction, return,
	// otherwise mark the new direction.
	mark := marked.Get(next)
	if mark&dir != 0 {
		return
	}
	marked.Put(next, mark|dir)

	newCell := src.Get(next)
	switch newCell {
	case '.':
		markEnergized(src, marked, next, dir)
	case '-':
		if dir == L || dir == R {
			markEnergized(src, marked, next, dir)
		} else {
			markEnergized(src, marked, next, L)
			markEnergized(src, marked, next, R)
		}
	case '|':
		if dir == U || dir == D {
			markEnergized(src, marked, next, dir)
		} else {
			markEnergized(src, marked, next, U)
			markEnergized(src, marked, next, D)
		}
	case '/':
		switch dir {
		case L:
			markEnergized(src, marked, next, D)
		case R:
			markEnergized(src, marked, next, U)
		case U:
			markEnergized(src, marked, next, R)
		case D:
			markEnergized(src, marked, next, L)
		}
	case '\\':
		switch dir {
		case L:
			markEnergized(src, marked, next, U)
		case R:
			markEnergized(src, marked, next, D)
		case U:
			markEnergized(src, marked, next, L)
		case D:
			markEnergized(src, marked, next, R)
		}
	}
}

func countMarked(marked Table[Direction]) int {
	return len(marked.GetMatchingCoords(func(v Direction) bool { return int(v) != 0 }))
}
