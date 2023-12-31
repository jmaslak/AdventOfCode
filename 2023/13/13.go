package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	var t Table[rune]

	sumA := 0
	sumB := 0
	scanner := bufio.NewScanner(os.Stdin)
	rowNumber := 0
	for scanner.Scan() {
		line := scanner.Text()
		if len(line) == 0 {
			sumA += getSmudged(t)
			sumB += getUnsmudged(t)
			t.Clear()
			rowNumber = 0
		} else {
			cols := []rune(line)
			for colNumber, v := range cols {
				t.PutXY(rowNumber, colNumber, v)
				colNumber++
			}
			rowNumber++
		}
	}
	sumA += getSmudged(t)
	sumB += getUnsmudged(t)

	fmt.Printf("Sum part A: %d\n", sumA)
	fmt.Printf("Sum part B: %d\n", sumB)
}

func getSmudged(t1 Table[rune]) int {
	t2 := t1.CopySwapXY()
	val1, _, _ := getValues(t1, -1, -1)
	val2, _, _ := getValues(t2, -1, -1)
	return val1 + val2*100
}

func getUnsmudged(t Table[rune]) int {
	rows := t.RowCount()
	cols := t.ColCount()

	t1 := t.Copy()
	t2 := t.CopySwapXY()

	_, small1, big1 := getValues(t1, -1, -1)
	_, small2, big2 := getValues(t2, -1, -1)

	for i := 0; i < rows; i++ {
		for j := 0; j < cols; j++ {
			c := t1.GetXY(i, j)
			var newC rune
			if c == '.' {
				newC = '#'
			} else {
				newC = '.'
			}

			t1.PutXY(i, j, newC)
			t2.PutXY(j, i, newC)

			r1, _, _ := getValues(t1, small1, big1)
			r2, _, _ := getValues(t2, small2, big2)

			if r1 > 0 || r2 > 0 {
				return r1 + r2*100
			}

			t1.PutXY(i, j, c)
			t2.PutXY(j, i, c)
		}
	}
	return 0
}

func getValues(t Table[rune], small int, big int) (int, int, int) {
	cols := t.ColCount()
	for i := 1; i < cols; i++ {
		var dist int
		if i < cols-i {
			dist = i
		} else {
			dist = cols - i
		}
		left := i - dist
		right := i + dist - 1

		if left == small && right == big {
			continue
		}

		flag := true
		for x := 1; x <= dist; x++ {
			l := t.GetCol(left + x - 1).GetRows()
			r := t.GetCol(right - x + 1).GetRows()

			if string(l) != string(r) {
				flag = false
			}
		}
		if flag {
			return i, left, right
		}
	}
	return 0, -1, -1
}
