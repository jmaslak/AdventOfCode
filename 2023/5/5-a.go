package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
)

type seed struct {
	id int
}

type rule struct {
	dest_id int
	src_id  int
	count   int
}

type mapping struct {
	dest_name string
	val       []rule
}

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	reNumbers := regexp.MustCompile("^seeds: ([0-9 ]+)$")
	reMap := regexp.MustCompile("^(.*)-to-(.*) map:$")

	seeds := make([]seed, 0, 0)
	conversions := make(map[string]mapping)
	src_map := ""
	dst_map := ""
	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			src_map = ""
			dst_map = ""
			continue
		} else if reNumbers.MatchString(line) {
			matches := reNumbers.FindStringSubmatch(line)
			for _, v := range strings.Split(matches[1], " ") {
				i, err := strconv.Atoi(v)
				if err != nil {
					fmt.Println(err)
					return
				}
				seeds = append(seeds, seed{id: i})
			}
			continue
		} else if reMap.MatchString(line) {
			matches := reMap.FindStringSubmatch(line)
			src_map = matches[1]
			dst_map = matches[2]
			dst_mapping := mapping{dest_name: dst_map, val: make([]rule, 0, 0)}

			conversions[src_map] = dst_mapping
		} else {
			matches := strings.Split(line, " ")
			dst_start, err := strconv.Atoi(matches[0])
			if err != nil {
				fmt.Println(err)
				return
			}
			src_start, err := strconv.Atoi(matches[1])
			if err != nil {
				fmt.Println(err)
				return
			}
			count, err := strconv.Atoi(matches[2])
			if err != nil {
				fmt.Println(err)
				return
			}

			node := rule{dest_id: dst_start, src_id: src_start, count: count}

			mappingval := conversions[src_map]
			mappingval.val = append(mappingval.val, node)
			conversions[src_map] = mappingval
		}

	}

	locations := make([]int, 0, 0)
	for _, aseed := range seeds {
		dst_name, val := get_location(aseed, conversions, "seed")
		if dst_name == "location" {
			locations = append(locations, val)
		}
	}

	min := -1
	for _, location := range locations {
		if min == -1 || min > location {
			min = location
		}
	}
	fmt.Print("Minimum location: ")
	fmt.Println(min)
}

func get_location(aseed seed, conversion map[string]mapping, src_name string) (string, int) {
	dest := conversion[src_name].dest_name
	for _, rule := range conversion[src_name].val {
		if aseed.id >= rule.src_id && (aseed.id < rule.src_id+rule.count) {
			delta := rule.src_id - rule.dest_id
			countdelta := aseed.id - rule.src_id
			dst_id := rule.src_id - delta + countdelta
			if dest == "location" {
				return "location", dst_id
			}

			lookupseed := seed{id: dst_id}
			return get_location(lookupseed, conversion, dest)
		}
	}

	// Do not change the ID
	if dest == "location" {
		return "location", aseed.id
	}
	return get_location(aseed, conversion, dest)
}
