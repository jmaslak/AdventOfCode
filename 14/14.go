package main

import (
	"fmt"
	"os"
)

type Direction int

const (
	N Direction = iota
	W
	S
	E
)

func main() {
	var t Table[rune]
	t.Read(os.Stdin, func(s string) []rune { return []rune(s) })

	t1 := t.Copy()
	tilt(t1, N)
	fmt.Printf("Sum part A: %d\n", weigh(t1))

	cycles := make(map[string]int)
	outs := make([]Table[rune], 0, 0)
	outs = append(outs, t)
	c := 0
	for {
		c++
		cycle(t)
		str := t.String()
		if cycles[str] > 0 {
			start := cycles[str]
			period := c - cycles[str]
			equiv := start + ((1_000_000_000 - start) % period)
			fmt.Printf("Sum part B: %d\n", weigh(outs[equiv]))
			break
		}
		cycles[str] = c
		outs = append(outs, t.Copy())
	}
}

func cycle(t Table[rune]) {
	tilt(t, N)
	tilt(t, W)
	tilt(t, S)
	tilt(t, E)
}

func tilt(t Table[rune], dir Direction) int {
	maxr := t.RowCount()
	maxc := t.ColCount()

	if dir == N {
		for col := 0; col < maxc; col++ {
			newrow := 0
			for row := 0; row < maxr; row++ {
				if t.GetXY(row, col) == '#' {
					newrow = row + 1
				} else if t.GetXY(row, col) == 'O' {
					t.PutXY(row, col, '.')
					t.PutXY(newrow, col, 'O')
					newrow++
				}
			}
		}
	} else if dir == W {
		for row := 0; row < maxr; row++ {
			newcol := 0
			for col := 0; col < maxc; col++ {
				if t.GetXY(row, col) == '#' {
					newcol = col + 1
				} else if t.GetXY(row, col) == 'O' {
					t.PutXY(row, col, '.')
					t.PutXY(row, newcol, 'O')
					newcol++
				}
			}
		}
	} else if dir == S {
		for col := 0; col < maxc; col++ {
			newrow := maxr - 1
			for row := maxr - 1; row >= 0; row-- {
				if t.GetXY(row, col) == '#' {
					newrow = row - 1
				} else if t.GetXY(row, col) == 'O' {
					t.PutXY(row, col, '.')
					t.PutXY(newrow, col, 'O')
					newrow--
				}
			}
		}
	} else if dir == E {
		for row := 0; row < maxr; row++ {
			newcol := maxc - 1
			for col := maxc - 1; col >= 0; col-- {
				if t.GetXY(row, col) == '#' {
					newcol = col - 1
				} else if t.GetXY(row, col) == 'O' {
					t.PutXY(row, col, '.')
					t.PutXY(row, newcol, 'O')
					newcol--
				}
			}
		}
	}
	return 0
}

func weigh(t Table[rune]) int {
	weight := 0
	for _, c := range t.GetCols() {
		for row, v := range c.GetRows() {
			if v == 'O' {
				weight += t.RowCount() - row
			}
		}
	}
	return weight
}
