import json
import os

transcript_path = r"C:\Users\User\.gemini\antigravity\brain\068df35f-91ee-4740-9ef4-9cc7d9377e9d\.system_generated\logs\transcript.jsonl"
full_transcript_path = r"C:\Users\User\.gemini\antigravity\brain\068df35f-91ee-4740-9ef4-9cc7d9377e9d\.system_generated\logs\transcript_full.jsonl"

with open(full_transcript_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

latest_content = ""
for line in lines:
    try:
        data = json.loads(line)
        if 'content' in data:
            c = data['content']
            if 'class _CoachDashboardScreenState extends State<CoachDashboardScreen>' in c and 'import \'package:flutter/material.dart\';' in c:
                latest_content = c
        if 'tool_calls' in data:
            for call in data['tool_calls']:
                if 'arguments' in call and 'CodeContent' in call['arguments']:
                    if 'class CoachDashboardScreen' in call['arguments']['CodeContent']:
                        latest_content = call['arguments']['CodeContent']
        
        # Also check outputs from Get-Content
        if data.get('type') == 'TOOL_RESPONSE' and 'Output' in data.get('content', ''):
             if 'class _CoachDashboardScreenState' in data['content']:
                  latest_content = data['content']
    except Exception as e:
        pass

if latest_content:
    with open('found_coach.txt', 'w', encoding='utf-8') as out:
        out.write(latest_content)
    print("Found it! Length:", len(latest_content))
else:
    print("Not found.")
