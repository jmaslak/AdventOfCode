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

func main() {
	basemap := map[string]int{
		"red":   12,
		"green": 13,
		"blue":  14,
	}
	scanner := bufio.NewScanner(os.Stdin)
	reGameLine := regexp.MustCompile("^Game ([0-9]+): (.*)")
	reGamePart := regexp.MustCompile("([0-9]+) (.*)")
	sum := 0
	sum2 := 0
	for scanner.Scan() {
		line := scanner.Text()
		matches := reGameLine.FindStringSubmatch(line)
		id, err := strconv.Atoi(matches[1])
		if err != nil {
			log.Println(err)
			return
		}
		str := matches[2]
		split := strings.Split(str, "; ")
		nope := false
		powerbase := map[string]int{
			"red":   0,
			"green": 0,
			"blue":  0,
		}
		for _, items := range split {
			parts := strings.Split(items, ", ")
			for _, part := range parts {
				matches = reGamePart.FindStringSubmatch(part)
				count, err := strconv.Atoi(matches[1])
				if err != nil {
					log.Println(err)
					return
				}
				itemtype := matches[2]

				if basemap[itemtype] < count {
					nope = true
				}

				if powerbase[itemtype] < count {
					powerbase[itemtype] = count
				}
			}
		}
		if !nope {
			sum = sum + id
		}
		power := powerbase["red"] * powerbase["green"] * powerbase["blue"]
		sum2 = sum2 + power
	}

	fmt.Println(sum)
	fmt.Println(sum2)
}
