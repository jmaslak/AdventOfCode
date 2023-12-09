package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
)

type Node struct {
	left  string
	right string
}

func main() {
	reParse := regexp.MustCompile("^(...) = [(](...), (...)[)]$")
	scanner := bufio.NewScanner(os.Stdin)

	scanner.Scan()
	directions := scanner.Text()
	scanner.Scan()

	nodes := make(map[string]Node)
	for scanner.Scan() {
		line := scanner.Text()
		matches := reParse.FindStringSubmatch(line)

		nodes[matches[1]] = Node{left: matches[2], right: matches[3]}
	}

	node := "AAA"
	step := 0
	for node != "ZZZ" {
		dir := directions[step%len(directions)]
		if dir == 'L' {
			node = nodes[node].left
		} else {
			node = nodes[node].right
		}
		step++
	}

	fmt.Print("Steps: ")
	fmt.Println(step)
}
