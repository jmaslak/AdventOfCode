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

	start := make([]string, 0, 0)
	for n, _ := range nodes {
		if n[2] == 'A' {
			start = append(start, n)
		}
	}

	steps := make([]int, 0, 0)
	for _, node := range start {
		step := 0
		for node[2] != 'Z' {
			dir := directions[step%len(directions)]
			if dir == 'L' {
				node = nodes[node].left
			} else {
				node = nodes[node].right
			}
			step++
		}
		steps = append(steps, step)
	}

	fmt.Print("Steps: ")
	fmt.Println(lcm(steps))
}

func lcm(numbers []int) int {
	a := numbers[0]
	b := numbers[1]

	var candidate int
	if a > b {
		candidate = (a / gcd(a, b)) * b
	} else {
		candidate = (b / gcd(a, b)) * a
	}

	if len(numbers) == 2 {
		return candidate
	}

	new_numbers := numbers[2:]
	new_numbers = append(new_numbers, candidate)
	return lcm(new_numbers)
}

func gcd(a, b int) int {
	if b == 0 {
		return a
	}
	return gcd(b, a%b)
}
