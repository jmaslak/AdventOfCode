package main

import (
	"fmt"
	"os"
	"sort"
)

type DistNode struct {
	distance int
	coord    Coord
}

func main() {
	var t Table[rune]
	t.Read(os.Stdin, func(s string) []rune { return []rune(s) })

	emptyRow := make(map[int]bool)
	for i, r := range t.GetRows() {
		emptyRow[i] = r.all(func(v rune) bool { return v == '.' })
	}

	emptyCol := make(map[int]bool)
	for i, c := range t.GetCols() {
		emptyCol[i] = c.all(func(v rune) bool { return v == '.' })
	}

	galaxies := t.GetMatchingCoords(func(v rune) bool { return v == '#' })

	fmt.Printf("Part A Sum: %d\n", getSums(t, 2, emptyRow, emptyCol, galaxies))
	fmt.Printf("Part B Sum: %d\n", getSums(t, 1_000_000, emptyRow, emptyCol, galaxies))
}

func getSums(t Table[rune], expansion int, emptyRow map[int]bool, emptyCol map[int]bool, galaxies []Coord) int {
	sum := 0
	for i := range galaxies {
		for j := range galaxies {
			if i >= j {
				continue
			}
			sum += dist(t, expansion, emptyRow, emptyCol, galaxies[i], galaxies[j])
		}
	}
	return sum
}

func dist(t Table[rune], expansion int, emptyRow map[int]bool, emptyCol map[int]bool, g1 Coord, g2 Coord) int {
	rows := append(make([]int, 0, 0), g1.Row(), g2.Row())
	cols := append(make([]int, 0, 0), g1.Col(), g2.Col())

	sort.Ints(rows)
	sort.Ints(cols)

	rowExpand := 0
	for i, v := range emptyRow {
		if v && rows[0] < i && rows[1] > i {
			rowExpand++
		}
	}

	colExpand := 0
	for i, v := range emptyCol {
		if v && cols[0] < i && cols[1] > i {
			colExpand++
		}
	}

	return rows[1] - rows[0] + cols[1] - cols[0] + (rowExpand * expansion) +
		(colExpand * expansion) - rowExpand - colExpand
}
