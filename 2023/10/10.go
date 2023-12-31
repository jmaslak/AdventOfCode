package main

import (
	"bufio"
	"fmt"
	"os"
)

type DistNode struct {
	distance int
	coord    Coord
}

func main() {
	var t Table[rune]
	row := 0
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		line := scanner.Text()
		cols := []rune(line)
		for col, v := range cols {
			t.PutXY(row, col, v)
			col++
		}
		row++
	}
	t.AddBorder('.')

	max := -1

	// Find "S" and initialize dist
	var start Coord
	var dist Table[int]
	for row = 0; row < t.RowCount(); row++ {
		for col := 0; col < t.ColCount(); col++ {
			if t.GetXY(row, col) == 'S' {
				start = Coord{row: row, col: col}
				dist.Put(start, 0)
			} else {
				dist.PutXY(row, col, max)
			}
		}
	}

	stack := make([]DistNode, 0, 0)
	up := t.Get(start.N())
	if up == '|' || up == '7' || up == 'F' {
		stack = append(stack, DistNode{distance: 1, coord: start.N()})
	}
	dn := t.Get(start.S())
	if dn == '|' || dn == 'L' || dn == 'J' {
		stack = append(stack, DistNode{distance: 1, coord: start.S()})
	}
	lt := t.Get(start.W())
	if lt == '-' || lt == 'L' || lt == 'F' {
		stack = append(stack, DistNode{distance: 1, coord: start.W()})
	}
	rt := t.Get(start.E())
	if rt == '-' || rt == '7' || rt == 'J' {
		stack = append(stack, DistNode{distance: 1, coord: start.E()})
	}

	for len(stack) > 0 {
		v := stack[0]
		stack = stack[1:]

		if dist.Get(v.coord) == -1 || v.distance < dist.Get(v.coord) {
			dist.Put(v.coord, v.distance)
			char := t.Get(v.coord)
			d := v.distance + 1
			if char == '-' {
				stack = append(stack, DistNode{distance: d, coord: v.coord.W()})
				stack = append(stack, DistNode{distance: d, coord: v.coord.E()})
			} else if char == '|' {
				stack = append(stack, DistNode{distance: d, coord: v.coord.N()})
				stack = append(stack, DistNode{distance: d, coord: v.coord.S()})
			} else if char == 'J' {
				stack = append(stack, DistNode{distance: d, coord: v.coord.N()})
				stack = append(stack, DistNode{distance: d, coord: v.coord.W()})
			} else if char == '7' {
				stack = append(stack, DistNode{distance: d, coord: v.coord.S()})
				stack = append(stack, DistNode{distance: d, coord: v.coord.W()})
			} else if char == 'F' {
				stack = append(stack, DistNode{distance: d, coord: v.coord.E()})
				stack = append(stack, DistNode{distance: d, coord: v.coord.S()})
			} else if char == 'L' {
				stack = append(stack, DistNode{distance: d, coord: v.coord.E()})
				stack = append(stack, DistNode{distance: d, coord: v.coord.N()})
			}
		}
	}

	steps := 0
	for row = 0; row < t.RowCount(); row++ {
		for col := 0; col < t.ColCount(); col++ {
			if dist.GetXY(row, col) > steps {
				steps = dist.GetXY(row, col)
			}
		}
	}

	var expanded Table[rune]
	for row = 0; row < dist.RowCount(); row++ {
		for col := 0; col < dist.ColCount(); col++ {
			expanded.PutXY(row*2, col*2, ' ')
			expanded.PutXY(row*2, col*2+1, ' ')
			expanded.PutXY(row*2+1, col*2, ' ')
			expanded.PutXY(row*2+1, col*2+1, ' ')
			if dist.GetXY(row, col) >= 0 {
				expanded.PutXY(row*2, col*2, t.GetXY(row, col))
				char := t.GetXY(row, col)
				if char == '-' {
					expanded.PutXY(row*2, col*2-1, '-')
					expanded.PutXY(row*2, col*2+1, '-')
				} else if char == '|' {
					expanded.PutXY(row*2-1, col*2, '|')
					expanded.PutXY(row*2+1, col*2, '|')
				} else if char == 'J' {
					expanded.PutXY(row*2-1, col*2, '|')
					expanded.PutXY(row*2, col*2-1, '-')
				} else if char == '7' {
					expanded.PutXY(row*2, col*2-1, '-')
					expanded.PutXY(row*2+1, col*2, '|')
				} else if char == 'F' {
					expanded.PutXY(row*2+1, col*2, '|')
					expanded.PutXY(row*2, col*2+1, '-')
				} else if char == 'L' {
					expanded.PutXY(row*2-1, col*2, '|')
					expanded.PutXY(row*2, col*2+1, '-')
				}
			}
		}
	}

	stack = append(stack, DistNode{coord: Coord{row: 0, col: 0}})
	inside := 0
	for len(stack) > 0 {
		v := stack[0]
		stack = stack[1:]

		row = v.coord.Row()
		col := v.coord.Col()
		if row < 0 || row > expanded.RowCount() || col < 0 || col > expanded.ColCount() {
			// Do nothing, out of bounds
		} else if expanded.Get(v.coord) == ' ' {
			expanded.Put(v.coord, 'O')

			for _, n := range expanded.Neighbors(v.coord, false) {
				stack = append(stack, DistNode{coord: n})
			}
		}
	}

	inside = 0
	for row = 0; row < expanded.RowCount(); row = row + 2 {
		for col := 0; col < expanded.ColCount(); col = col + 2 {
			if expanded.GetXY(row, col) == ' ' {
				inside++
			}
		}
	}

	fmt.Printf("Steps: %d\n", steps)
	fmt.Printf("Inside: %d\n", inside)
}
