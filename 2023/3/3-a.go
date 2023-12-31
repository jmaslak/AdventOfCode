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
	scanner := bufio.NewScanner(os.Stdin)
	lineLength := 0
	for scanner.Scan() {
		line := scanner.Text()
		if lineLength == 0 {
			lineLength = len(line) + 2
			list = append(list, []rune(strings.Repeat(".", lineLength)))
		}
		list = append(list, []rune("."+line+"."))
	}
	list = append(list, []rune(strings.Repeat(".", lineLength)))

	candidate := 0
	start := -1
	end := -1
	sum := 0
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
						sum = sum + candidate
					}
					candidate = 0
					start = -1
					end = -1
				}
			}
		}
	}

	fmt.Print("Sum of part numbers: ")
	fmt.Println(sum)
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
