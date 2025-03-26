# Fixing Browser-Use with Qwen on Ollama

This guide provides steps to create a custom Ollama model that fixes the JSON format issue
that occurs when using Qwen models with Browser-Use.

## Problem Description

When using Qwen 2.5:7B with Browser-Use through Ollama, the model returns JSON responses as 
lists/arrays `[{ "key": "value" }]` instead of single objects `{ "key": "value" }`.
This causes errors in Browser-Use that look like:

```
TypeError: src.agent.custom_views.CustomAgentOutput() argument after ** must be a mapping, not list
```

## Solution: Create a Custom Ollama Model with Fixed Output Format

Follow these steps on your Ollama server (192.168.20.22):

### 1. Automated Method (Recommended)

Use our provided script:

```bash
# Navigate to the scripts directory
cd /home/ee/CascadeProjects/Qwen2.5-7B-ollama/scripts/ollama

# Run the script
./create-browser-qwen.sh
```

### 2. Manual Method

#### a. Create a Modelfile

Create a file named `Modelfile` with the following content:

```
FROM qwen2.5:7b
PARAMETER temperature 0.3
SYSTEM """
You are a helpful AI assistant that follows instructions precisely.
IMPORTANT: Always format your responses as a single JSON object, never as a list or array.
For example, use {"key": "value"} instead of [{"key": "value"}].
When asked to generate structured data, ensure it is a single JSON object at the root level.
Always validate your responses to ensure they match this format requirement.
"""
```

#### b. Build the Custom Model

Open a terminal on your Ollama server and run:

```bash
# Navigate to the directory containing your Modelfile
cd /path/to/directory/with/modelfile

# Create a new model called 'browser-qwen'
ollama create browser-qwen -f Modelfile
```

This will create a new model based on Qwen 2.5:7B but with special instructions to format outputs correctly.

### 3. Test the Model (Optional but Recommended)

Test that the model correctly formats JSON responses:

```bash
ollama run browser-qwen "Generate a JSON response with user information including name and age"
```

Verify that the response is a single JSON object (starts with `{`) and not a list (doesn't start with `[`).

### 4. Update Browser-Use Configuration

On your client machine, update your `.env` file to use the new model:

```
OLLAMA_ENDPOINT=http://192.168.20.22:11434
```

And in the Browser-Use web interface:
1. Set LLM Provider: "ollama"
2. Set Model Name: "browser-qwen" (instead of "qwen2.5:7b")
3. Set Base URL: "http://192.168.20.22:11434"
4. Leave API Key blank (Ollama doesn't require one)

### 5. Restart Browser-Use

Restart the Browser-Use web interface to apply these changes.

## Troubleshooting

If you continue to experience issues:

1. Check that the model was created successfully with `ollama list`
2. Verify the system prompt is being applied by testing simple queries
3. Try decreasing the temperature further (to 0.1 or 0) to make outputs more deterministic
4. Ensure your Ollama server is running the latest version (1.1.0+)
