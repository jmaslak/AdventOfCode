package main

import (
	"bufio"
	"fmt"
	"io"
)

type Coord struct {
	row int
	col int
}

type Row[T any] struct {
	cols []T
}

type Col[T any] struct {
	rows []T
}

type Table[T any] struct {
	rows []Row[T]
}

func (r Row[T]) GetCols() []T {
	return r.cols
}

func (r Row[T]) all(f func(T) bool) bool {
	for _, v := range r.cols {
		if !f(v) {
			return false
		}
	}
	return true
}

func (r Row[T]) Length() int {
	return len(r.cols)
}

func (c Col[T]) GetRows() []T {
	return c.rows
}

func (c Col[T]) all(f func(T) bool) bool {
	for _, v := range c.rows {
		if !f(v) {
			return false
		}
	}
	return true
}

func (c Col[T]) Length() int {
	return len(c.rows)
}

func (t Table[T]) RowCount() int {
	return len(t.rows)
}

func (t Table[T]) ColCount() int {
	max := 0
	for _, row := range t.rows {
		if max < len(row.cols) {
			max = len(row.cols)
		}
	}
	return max
}

func (t Table[T]) Get(coord Coord) T {
	row := coord.row
	col := coord.col

	return t.GetXY(row, col)
}

func (t Table[T]) GetXY(row, col int) T {
	if len(t.rows) > row {
		if len(t.rows[row].cols) > col {
			return t.rows[row].cols[col]
		}
	}
	var n T
	return n
}

func (t *Table[T]) Put(coord Coord, node T) {
	row := coord.row
	col := coord.col

	t.PutXY(row, col, node)
}

func (t *Table[T]) PutXY(row, col int, node T) {
	for len(t.rows) <= row {
		var r Row[T]
		r.cols = make([]T, col, col)
		t.rows = append(t.rows, r)
	}
	for len(t.rows[row].cols) <= col {
		var n T
		t.rows[row].cols = append(t.rows[row].cols, n)
	}
	t.rows[row].cols[col] = node
}

func (t Table[T]) GetRows() []Row[T] {
	return t.rows
}

func (t Table[T]) GetCols() []Col[T] {
	cols := make([]Col[T], 0, 0)
	rotated := t.CopySwapXY()
	for _, r := range rotated.GetRows() {
		var col Col[T]
		col.rows = r.GetCols()
		cols = append(cols, col)
	}
	return cols
}

func (t Table[T]) GetCol(col int) Col[T] {
	var row []T
	for i := 0; i < t.RowCount(); i++ {
		row = append(row, t.GetXY(i, col))
	}
	return Col[T]{rows: row}
}

func (t Table[T]) GetRow(row int) Row[T] {
	return t.rows[row]
}

func (t Table[T]) Copy() Table[T] {
	var newTable Table[T]
	for i, r := range t.GetRows() {
		for j, v := range r.GetCols() {
			newTable.PutXY(i, j, v)
		}
	}
	return newTable
}

func (t Table[T]) CopySwapXY() Table[T] {
	var newTable Table[T]
	for i, r := range t.GetRows() {
		for j, v := range r.GetCols() {
			newTable.PutXY(j, i, v)
		}
	}
	return newTable
}

func (t *Table[T]) AddBorder(node T) {
	rows := t.RowCount()
	cols := t.ColCount()

	newRows := make([]Row[T], rows+2, rows+2)
	copy(newRows[1:], t.rows)

	// Fill in top an dbottom
	newRows[0].cols = make([]T, cols+2, cols+2)
	newRows[len(newRows)-1].cols = make([]T, cols+2, cols+2)
	for i := 0; i < cols+2; i++ {
		newRows[0].cols[i] = node
		newRows[len(newRows)-1].cols[i] = node
	}

	// Copy in old data and add left/right borders
	for i := 0; i < rows; i++ {
		newCol := make([]T, cols+2, cols+2)
		copy(newCol[1:], t.rows[i].cols)
		newCol[0] = node
		newCol[len(newCol)-1] = node
		newRows[i+1].cols = newCol
	}

	t.rows = newRows
}

func (t Table[T]) Print(format string) {
	for row := 0; row < t.RowCount(); row++ {
		for col := 0; col < t.ColCount(); col++ {
			v := t.Get(Coord{col: col, row: row})
			fmt.Printf(format, v)
		}
		fmt.Println("")
	}
}

func (t Table[T]) Neighbors(coord Coord, include_diagonals bool) []Coord {
	out := make([]Coord, 0, 0)

	if coord.N().Row() >= 0 {
		out = append(out, coord.N())
	}
	if coord.S().Row() < t.RowCount() {
		out = append(out, coord.S())
	}
	if coord.W().Col() >= 0 {
		out = append(out, coord.W())
	}
	if coord.E().Col() < t.ColCount() {
		out = append(out, coord.E())
	}

	if include_diagonals {
		node := coord.N().W()
		if node.Row() >= 0 && node.Col() >= 0 {
			out = append(out, node)
		}
		node = coord.N().E()
		if node.Row() >= 0 && node.Col() < t.ColCount() {
			out = append(out, node)
		}
		node = coord.S().W()
		if node.Row() < t.RowCount() && node.Col() >= 0 {
			out = append(out, node)
		}
		node = coord.N().E()
		if node.Row() < t.RowCount() && node.Col() < t.ColCount() {
			out = append(out, node)
		}
	}

	return out
}

func (t Table[T]) GetMatchingCoords(matcher func(T) bool) []Coord {
	ret := make([]Coord, 0, 0)
	for i, r := range t.GetRows() {
		for j, v := range r.GetCols() {
			if matcher(v) {
				ret = append(ret, Coord{row: i, col: j})
			}
		}
	}
	return ret
}

func (t *Table[T]) Clear() {
	t.rows = make([]Row[T], 0, 0)
}

func (t *Table[T]) Read(r io.Reader, code func(string) []T) {
	t.Clear()
	row := 0
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		line := scanner.Text()
		cols := code(line)
		for col, v := range cols {
			t.PutXY(row, col, v)
		}
		row++
	}
}

func (t *Table[rune]) String() string {
	out := ""
	for _, row := range t.GetRows() {
		for _, v := range row.GetCols() {
			out = out + fmt.Sprintf("%s", v)
		}
	}
	return out
}

func (c Coord) N() Coord {
	return Coord{row: c.row - 1, col: c.col}
}

func (c Coord) S() Coord {
	return Coord{row: c.row + 1, col: c.col}
}

func (c Coord) W() Coord {
	return Coord{row: c.row, col: c.col - 1}
}

func (c Coord) E() Coord {
	return Coord{row: c.row, col: c.col + 1}
}

func (c Coord) Print() {
	fmt.Printf("%d, %d\n", c.row, c.col)
}

func (c Coord) OOB() bool {
	// Verifies the coordinates aren't out of bounds (important
	// after a N/S/E/W() operation)
	if c.row < 0 || c.col < 0 {
		return true
	}
	return false
}

func (c Coord) Row() int {
	return c.row
}

func (c Coord) Col() int {
	return c.col
}
