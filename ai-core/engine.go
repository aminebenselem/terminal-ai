package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

// Suggestion represents an AI-generated command suggestion
type Suggestion struct {
	Command string `json:"command"`
}

// GeminiRequest represents the payload structure for Gemini API
type GeminiRequest struct {
	CommandHistory    []string `json:"command_history"`      // array of past commands
	LastCommandOutput string   `json:"last_command_output"`  // output from last executed command
	UserClipBoard     string   `json:"user_clipboard"`       // content from user's clipboard
	UserQuery         string   `json:"user_query"`           // current user input/query
}

// GeminiResponse represents the response from Gemini API
type GeminiResponse struct {
	Candidates []struct {
		Content struct {
			Parts []struct {
				Text string `json:"text"`
			} `json:"parts"`
		} `json:"content"`
	} `json:"candidates"`
}

// callGeminiAPI sends a request to Google Gemini API and returns a command suggestion
func callGeminiAPI(payload GeminiRequest) (string, error) {
	// Get API key from environment variable
	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		return "", fmt.Errorf("GEMINI_API_KEY environment variable not set")
	}

	// Prepare the request body with context
	prompt := fmt.Sprintf(`You are a terminal assistant. Given the following context:
Command History: %s
Last Output: %s
Clipboard: %s

User Query: %s

Respond with ONLY the shell command to execute (no explanation, no markdown, just the raw command).`, 
		strings.Join(payload.CommandHistory, "; "),
		payload.LastCommandOutput,
		payload.UserClipBoard,
		payload.UserQuery)

	// Create request to Gemini API
	url := "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-live:generateContent?key=" + apiKey

	reqBody := map[string]interface{}{
		"contents": []map[string]interface{}{
			{
				"parts": []map[string]string{
					{"text": prompt},
				},
			},
		},
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return "", fmt.Errorf("failed to marshal request: %w", err)
	}

	// Make HTTP request with timeout to avoid hanging the shell adapter
	timeoutSec := 5 // default timeout seconds
	if v := os.Getenv("TERMINAL_AI_TIMEOUT"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 {
			timeoutSec = n
		}
	}

	if os.Getenv("TERMINAL_AI_DEBUG") == "1" {
		fmt.Fprintf(os.Stderr, "[terminal-ai] calling Gemini with %d s timeout\n", timeoutSec)
	}

	client := &http.Client{Timeout: time.Duration(timeoutSec) * time.Second}
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonBody))
	if err != nil {
		return "", fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to call Gemini API: %w", err)
	}
	defer resp.Body.Close()

	// Check response status
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("Gemini API error (status %d): %s", resp.StatusCode, string(body))
	}

	// Parse response
	var geminiResp GeminiResponse
	if err := json.NewDecoder(resp.Body).Decode(&geminiResp); err != nil {
		return "", fmt.Errorf("failed to parse API response: %w", err)
	}

	// Extract command from response
	if len(geminiResp.Candidates) == 0 || len(geminiResp.Candidates[0].Content.Parts) == 0 {
		return "", fmt.Errorf("empty response from Gemini API")
	}

	command := strings.TrimSpace(geminiResp.Candidates[0].Content.Parts[0].Text)
	return command, nil
}

// generateSuggestion takes user input and context to generate a command suggestion
func generateSuggestion(input string) Suggestion {
	// Create Gemini request payload
	payload := GeminiRequest{
		CommandHistory:    []string{}, // TODO: Get from shell history
		LastCommandOutput: "",         // TODO: Capture from last command
		UserClipBoard:     "",         // TODO: Read from system clipboard
		UserQuery:         input,
	}

	// Optional offline mode: skip remote calls entirely
	if os.Getenv("TERMINAL_AI_OFFLINE") == "1" {
		if os.Getenv("TERMINAL_AI_DEBUG") == "1" {
			fmt.Fprintln(os.Stderr, "[terminal-ai] offline mode enabled, echoing input")
		}
		return Suggestion{Command: input}
	}

	// Call Gemini API to get suggestion (with timeout and errors handled)
	command, err := callGeminiAPI(payload)
	if err != nil {
		// Fallback: return user input if API fails (never hang adapter)
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		return Suggestion{Command: input}
	}

	return Suggestion{Command: command}
}

func main() {
	// Require at least one argument (the user query)
	if len(os.Args) < 2 {
		os.Exit(1)
	}

	// Join all arguments as the user query
	query := strings.Join(os.Args[1:], " ")
	suggestion := generateSuggestion(query)

	// Output JSON for adapter to parse
	if os.Getenv("TERMINAL_AI_JSON") == "1" {
		output, _ := json.Marshal(suggestion)
		fmt.Println(string(output))
	} else {
		fmt.Println(suggestion.Command)
	}
}
