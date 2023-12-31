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
	id_start int
	id_end   int
}

type rule struct {
	dest_id_start int
	dest_id_end   int
	src_id_start  int
	src_id_end    int
}

type mapping struct {
	dest_name string
	val       []rule
}

type returns struct {
	id_start  int
	id_end    int
	dest_name string
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
			splits := strings.Split(matches[1], " ")
			for i := 0; i < len(splits); i = i + 2 {
				v1 := splits[i]
				v2 := splits[i+1]
				i1, err := strconv.Atoi(v1)
				if err != nil {
					fmt.Println(err)
					return
				}
				i2, err := strconv.Atoi(v2)
				if err != nil {
					fmt.Println(err)
					return
				}
				aseed := seed{id_start: i1, id_end: i1 + i2 - 1}
				seeds = append(seeds, aseed)
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

			node := rule{
				dest_id_start: dst_start,
				dest_id_end:   dst_start + count - 1,
				src_id_start:  src_start,
				src_id_end:    src_start + count - 1,
			}

			mappingval := conversions[src_map]
			mappingval.val = append(mappingval.val, node)
			conversions[src_map] = mappingval
		}

	}

	locations := make([]returns, 0, 0)

	for _, aseed := range seeds {
		rets := get_location(aseed, conversions, "seed")
		locations = append(locations, rets...)
	}

	min := -1
	for _, location := range locations {
		if min == -1 || min > location.id_start {
			min = location.id_start
		}
	}
	fmt.Print("Minimum location: ")
	fmt.Println(min)
}

func get_location(aseed seed, conversion map[string]mapping, src_name string) []returns {
	dest := conversion[src_name].dest_name
	for _, rule := range conversion[src_name].val {
		range_start := rule.src_id_start
		range_end := rule.src_id_end

		delta := rule.src_id_start - rule.dest_id_start

		ranges := make([]seed, 0, 0)
		var check seed
		if aseed.id_start >= range_start && aseed.id_end <= range_end {
			check = aseed
		} else if aseed.id_start < range_start && aseed.id_end >= range_start && aseed.id_end <= range_end {
			// We start before the range
			ranges = append(ranges, seed{id_start: aseed.id_start, id_end: range_start - 1})
			check = seed{id_start: range_start, id_end: aseed.id_end}
		} else if aseed.id_start >= range_start && aseed.id_start <= range_end {
			// We start inside the ragne, but end outside it
			ranges = append(ranges, seed{id_start: range_end + 1, id_end: aseed.id_end})
			check = seed{id_start: aseed.id_start, id_end: range_end}
		} else if aseed.id_start < range_start && aseed.id_end > range_end {
			// We start before, end after
			ranges = append(ranges, seed{id_start: aseed.id_start, id_end: range_start - 1})
			ranges = append(ranges, seed{id_start: range_end + 1, id_end: aseed.id_end})
			check = seed{id_start: range_start, id_end: range_end}
		} else {
			continue
		}

		rets := make([]returns, 0, 0)
		for _, next_range := range ranges {
			rets = append(rets, get_location(next_range, conversion, src_name)...)
		}

		countdelta_start := check.id_start - range_start
		countdelta_end := check.id_end - range_start
		dst_id_start := range_start - delta + countdelta_start
		dst_id_end := range_start - delta + countdelta_end

		if dest == "location" {
			rets = append(rets, returns{id_start: dst_id_start, id_end: dst_id_end, dest_name: dest})
		} else {
			rets = append(rets, get_location(seed{id_start: dst_id_start, id_end: dst_id_end}, conversion, dest)...)
		}
		return rets
	}

	// Don't change the ID
	if dest == "location" {
		rets := make([]returns, 0, 0)
		rets = append(rets, returns{id_start: aseed.id_start, id_end: aseed.id_end, dest_name: dest})
		return rets
	}
	return get_location(aseed, conversion, dest)
}
