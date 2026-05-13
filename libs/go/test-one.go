// The test-one-go tool parses the provided HTML file and print the microformats found.
package main

import (
	"encoding/json"
	"fmt"
	"net/url"
	"os"
	"willnorris.com/go/microformats"
)

func main() {
	baseStr := os.Args[2]
	baseURL, _ := url.Parse(baseStr)

	f, err := os.Open(os.Args[1])
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	defer f.Close()

	data := microformats.Parse(f, baseURL)

	json, _ := json.MarshalIndent(data, "", "  ")
	fmt.Println(string(json))
}
