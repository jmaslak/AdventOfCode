package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"regexp"
	"strconv"
	"strings"
)

type lensStruct struct {
	label string
	focal int
}

var reParse = regexp.MustCompile("^(.*)([-=])(.*)$")

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.Split(line, ",")

		sum := 0
		for _, part := range parts {
			sum += hash(part)
		}
		fmt.Printf("Sum part A: %d\n", sum)

		sum = hashmap(parts)
		fmt.Printf("Sum part B: %d\n", sum)
	}
}

func hash(str string) int {
	sum := 0
	for _, c := range str {
		sum += int(c)
		sum *= 17
		sum = sum % 256
	}
	return sum
}

func hashmap(orders []string) int {
	boxes := make([][]lensStruct, 256, 256)
	for _, order := range orders {
		matches := reParse.FindStringSubmatch(order)
		lens := matches[1]
		op := matches[2]
		focal := atoi(matches[3])

		box := hash(lens)
		if op == "-" {
			newContents := make([]lensStruct, 0, 0)
			for _, ele := range boxes[box] {
				if ele.label != lens {
					newContents = append(newContents, ele)
				}
			}
			boxes[box] = newContents
		} else if op == "=" {
			contents := boxes[box]
			flag := false
			for i, ele := range contents {
				if ele.label == lens {
					flag = true
					contents[i].focal = focal
				}
			}
			if !flag {
				contents = append(contents, lensStruct{label: lens, focal: focal})
				boxes[box] = contents
			}
		}
	}

	sum := 0
	for box, contents := range boxes {
		for i, ele := range contents {
			sum += (1 + box) * (1 + i) * ele.focal
		}
	}
	return sum
}

func atoi(str string) int {
	if str == "" {
		return 0
	}
	i, err := strconv.Atoi(str)
	if err != nil {
		log.Fatalf("Could not convert from string %+v", err)
	}
	return i
}
