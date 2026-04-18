package services

import (
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"time"
)

type Converter struct {
	rates map[string]float64
}

func NewConverter(base string) (*Converter, error) {
	now := time.Now()
	firstDay := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
	url := fmt.Sprintf("https://api.frankfurter.dev/v2/rates?date=%s&base=%s", firstDay.Format("2006-01-02"), base)

	resp, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch rates: %w", err)
	}
	defer resp.Body.Close()

	// ✅ Parse as array to match v2 response shape
	var entries []struct {
		Quote string  `json:"quote"`
		Rate  float64 `json:"rate"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&entries); err != nil {
		return nil, fmt.Errorf("failed to decode: %w", err)
	}
	if len(entries) == 0 {
		return nil, fmt.Errorf("empty rates response for base %s", base)
	}

	// Build the map
	rates := make(map[string]float64, len(entries)+1)
	for _, e := range entries {
		rates[e.Quote] = e.Rate
	}
	rates[base] = 1.0 // include base itself

	return &Converter{rates: rates}, nil
}
func (c *Converter) CrossRate(from, to string) (float64, error) {
	fromRate, ok := c.rates[from]
	if !ok {
		return 0, fmt.Errorf("unknown currency: %s", from)
	}
	toRate, ok := c.rates[to]
	if !ok {
		return 0, fmt.Errorf("unknown currency: %s", to)
	}
	raw := toRate / fromRate
	factor := math.Pow(10, 10)
	return math.Round(raw*factor) / factor, nil
}
