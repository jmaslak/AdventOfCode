package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"unicode"
)

func main() {
	list := make([][]rune, 0, 0)
	gears := make([][][]int, 0, 0)
	scanner := bufio.NewScanner(os.Stdin)
	lineLength := 0
	for scanner.Scan() {
		line := scanner.Text()
		if lineLength == 0 {
			lineLength = len(line) + 2
			list = append(list, []rune(strings.Repeat(".", lineLength)))
			gears = append(gears, make([][]int, lineLength, lineLength))
		}
		list = append(list, []rune("."+line+"."))
		gears = append(gears, make([][]int, lineLength, lineLength))
	}
	list = append(list, []rune(strings.Repeat(".", lineLength)))
	gears = append(gears, make([][]int, lineLength, lineLength))

	candidate := 0
	start := -1
	end := -1
	for rowIndex, row := range list {
		for colIndex, char := range row {
			if unicode.IsDigit(char) {
				if start < 0 {
					end = colIndex
					start = colIndex
				}
				i, err := strconv.Atoi(string(char))
				if err != nil {
					log.Println(err)
					return
				}
				candidate = candidate*10 + i
			} else {
				if start > 0 {
					end = colIndex - 1
					if hasSymbolTouching(rowIndex, start, end, list) {
						addToGear(candidate, rowIndex, start, end, list, gears)
					}
					candidate = 0
					start = -1
					end = -1
				}
			}
		}
	}

	sum := 0
	for _, row := range gears {
		for _, col := range row {
			if len(col) == 2 {
				sum = sum + col[0]*col[1]
			}
		}
	}
	fmt.Print("Sum of gears: ")
	fmt.Println(sum)
	// for _, line := range list {
	// fmt.Println(string(line))
	//}
}

func hasSymbolTouching(rowIndex int, start int, end int, list [][]rune) bool {
	rowMin := rowIndex - 1
	rowMax := rowIndex + 1
	colMin := start - 1
	colMax := end + 1

	for row := rowMin; row <= rowMax; row++ {
		for col := colMin; col <= colMax; col++ {
			if list[row][col] != []rune(".")[0] && !unicode.IsDigit(list[row][col]) {
				return true
			}
		}
	}
	return false
}

func addToGear(candidate int, rowIndex int, start int, end int, list [][]rune, gears [][][]int) {
	rowMin := rowIndex - 1
	rowMax := rowIndex + 1
	colMin := start - 1
	colMax := end + 1

	for row := rowMin; row <= rowMax; row++ {
		for col := colMin; col <= colMax; col++ {
			if list[row][col] == []rune("*")[0] {
				gears[row][col] = append(gears[row][col], candidate)
			}
		}
	}
}
