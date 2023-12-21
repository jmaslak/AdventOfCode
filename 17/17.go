package main

import (
	"fmt"
	"math"
	"os"
	"runtime/pprof"
)

type Direction int

const (
	H Direction = iota
	V
)

type Edge struct {
	C    Coord
	Cost int
}

type Edges struct {
	H []Edge
	V []Edge
}

type Costs struct {
	H int
	V int
}

type StackEntry struct {
	C    Coord
	Dir  Direction
	Cost int
}

func main() {
	f, _ := os.Create("prof.prof")
	pprof.StartCPUProfile(f)
	defer pprof.StopCPUProfile()

	var t Table[int]
	t.Read(os.Stdin, func(s string) []int {
		ret := make([]int, len(s), len(s))
		for i, r := range s {
			ret[i] = int(r - '0')
		}
		return ret
	})

	fmt.Printf("Heat loss part A: %d\n", findMinCost(t, 1, 3))
	fmt.Printf("Heat loss part B: %d\n", findMinCost(t, 4, 10))
}

func findMinCost(t Table[int], minDist int, maxDist int) int {
	edges := getEdges(t, minDist, maxDist)
	costs := getCosts(edges)

	nodeCosts := costs.GetXY(t.RowCount()-1, t.ColCount()-1)
	if nodeCosts.H < nodeCosts.V {
		return nodeCosts.H
	}
	return nodeCosts.V
}

func getEdges(t Table[int], minDist int, maxDist int) Table[Edges] {
	maxi := t.RowCount()
	maxj := t.ColCount()

	var edges Table[Edges]

	for i, row := range t.GetRows() {
		for j := range row.GetCols() {
			var e Edges

			// Vertical edges
			sumUp := 0
			sumDn := 0
			for di := 1; di <= maxDist; di++ {
				if i+di < maxi {
					sumUp += t.GetXY(i+di, j)
					c := Coord{row: i + di, col: j}
					if di >= minDist {
						e.V = append(e.V, Edge{C: c, Cost: sumUp})
					}
				}
				if i-di >= 0 {
					sumDn += t.GetXY(i-di, j)
					c := Coord{row: i - di, col: j}
					if di >= minDist {
						e.V = append(e.V, Edge{C: c, Cost: sumDn})
					}
				}
			}

			// Horizontal edges
			sumUp = 0
			sumDn = 0
			for dj := 1; dj <= maxDist; dj++ {
				if j+dj < maxj {
					sumUp += t.GetXY(i, j+dj)
					c := Coord{row: i, col: j + dj}
					if dj >= minDist {
						e.H = append(e.H, Edge{C: c, Cost: sumUp})
					}
				}
				if j-dj >= 0 {
					sumDn += t.GetXY(i, j-dj)
					c := Coord{row: i, col: j - dj}
					if dj >= minDist {
						e.H = append(e.H, Edge{C: c, Cost: sumDn})
					}
				}
			}

			// Write out to table
			edges.PutXY(i, j, e)
		}
	}

	return edges
}

func getCosts(edges Table[Edges]) Table[Costs] {
	var costs Table[Costs]
	for i := edges.RowCount() - 1; i >= 0; i-- { // Backwards because more efficient
		for j := edges.ColCount() - 1; j >= 0; j-- {
			costs.PutXY(i, j, Costs{H: math.MaxInt, V: math.MaxInt})
		}
	}

	stack := make([]StackEntry, 2, 2)
	stack = append(stack, StackEntry{Dir: H}, StackEntry{Dir: V})
	for len(stack) > 0 {
		top := stack[len(stack)-1]
		stack = stack[:len(stack)-1]

		me := costs.Get(top.C)
		if top.Dir == V && top.Cost < me.V {
			me.V = top.Cost
		} else if top.Dir == H && top.Cost < me.H {
			me.H = top.Cost
		} else {
			// Not cheaper
			continue
		}
		costs.Put(top.C, me)

		// We change direction for the next visits!
		if top.Dir == V {
			for _, visit := range edges.Get(top.C).H {
				stack = append(stack, StackEntry{C: visit.C, Cost: visit.Cost + top.Cost, Dir: H})
			}
		} else {
			for _, visit := range edges.Get(top.C).V {
				stack = append(stack, StackEntry{C: visit.C, Cost: visit.Cost + top.Cost, Dir: V})
			}
		}
	}

	return costs
}
