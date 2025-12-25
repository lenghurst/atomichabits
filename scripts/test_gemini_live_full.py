#!/usr/bin/env python3
"""
Gemini Live API Full Test - Match Flutter Implementation Exactly
Phase 34.4g: Diagnose why Flutter fails but Python works

This script replicates the exact Flutter setup message to find the issue.
"""

import asyncio
import json
import os
import sys
import time
from datetime import datetime

import websockets

MODEL = "gemini-2.5-flash-native-audio-preview-12-2025"
WS_ENDPOINT = "wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent"

# System instruction from Flutter VoiceCoachScreen
SYSTEM_INSTRUCTION = """You are The Pact's voice coach helping users create their first habit.

Your role:
1. Greet them warmly and ask for their name
2. Ask about their identity: "I want to be the type of person who..."
3. Help them design a tiny habit using James Clear's principles
4. Extract: habit name, frequency, time, location, trigger

Keep responses SHORT (1-2 sentences). This is voice, not text.
Be warm, encouraging, and conversational.
Use British English spelling and phrasing."""

def log(msg):
    timestamp = datetime.now().strftime("%H:%M:%S.%f")[:-3]
    print(f"[{timestamp}] {msg}")

async def test_with_system_instruction(api_key: str):
    """Test with the exact Flutter setup message including systemInstruction"""
    log(f"\n{'='*60}")
    log(f"TESTING WITH SYSTEM INSTRUCTION")
    log(f"{'='*60}")
    
    url = f"{WS_ENDPOINT}?key={api_key}"
    
    # Exact Flutter setup message
    setup_message = {
        "setup": {
            "model": f"models/{MODEL}",
            "generationConfig": {
                "responseModalities": ["AUDIO"],
                "speechConfig": {
                    "voiceConfig": {
                        "prebuiltVoiceConfig": {
                            "voiceName": "Kore"
                        }
                    }
                }
            },
            "systemInstruction": {
                "parts": [{"text": SYSTEM_INSTRUCTION}]
            }
        }
    }
    
    log(f"Setup message (truncated):")
    log(f"  model: models/{MODEL}")
    log(f"  responseModalities: [AUDIO]")
    log(f"  voiceName: Kore")
    log(f"  systemInstruction: {len(SYSTEM_INSTRUCTION)} chars")
    
    start_time = time.time()
    
    try:
        log("Opening WebSocket connection...")
        async with websockets.connect(url, close_timeout=5) as ws:
            elapsed = (time.time() - start_time) * 1000
            log(f"✅ WebSocket connected ({elapsed:.0f}ms)")
            
            # Send setup message
            log("Sending setup message...")
            await ws.send(json.dumps(setup_message))
            log("Setup message sent, waiting for response...")
            
            # Wait for setupComplete
            try:
                response = await asyncio.wait_for(ws.recv(), timeout=15)
                elapsed = (time.time() - start_time) * 1000
                
                data = json.loads(response)
                log(f"📨 Response received ({elapsed:.0f}ms)")
                
                if "setupComplete" in data:
                    log(f"✅ SUCCESS with systemInstruction!")
                    
                    # Now test sending a text message with thoughtSignature
                    log("\n--- Testing text message with thoughtSignature ---")
                    text_message = {
                        "clientContent": {
                            "turns": [{
                                "role": "user",
                                "parts": [{"text": "Hello, I want to build a habit"}]
                            }],
                            "turnComplete": True
                        },
                        "thoughtSignature": "test_signature_12345"  # This might cause issues!
                    }
                    log("Sending text message with thoughtSignature...")
                    await ws.send(json.dumps(text_message))
                    
                    try:
                        response2 = await asyncio.wait_for(ws.recv(), timeout=10)
                        data2 = json.loads(response2)
                        log(f"📨 Response to text: {json.dumps(data2)[:300]}...")
                        
                        if "error" in data2:
                            log(f"❌ Error with thoughtSignature: {data2['error']}")
                        else:
                            log("✅ Text message with thoughtSignature accepted")
                            
                    except asyncio.TimeoutError:
                        log("⚠️ Timeout waiting for text response (may be generating audio)")
                    
                    return True
                    
                elif "error" in data:
                    error_msg = data.get("error", {}).get("message", str(data))
                    log(f"❌ Error from server: {error_msg}")
                    return False
                else:
                    log(f"⚠️ Unexpected response: {json.dumps(data)[:500]}")
                    return False
                    
            except asyncio.TimeoutError:
                elapsed = (time.time() - start_time) * 1000
                log(f"❌ TIMEOUT after {elapsed:.0f}ms")
                return False
                
    except Exception as e:
        log(f"❌ Connection error: {type(e).__name__}: {e}")
        return False

async def main():
    api_key = os.environ.get("GEMINI_API_KEY")
    if len(sys.argv) > 1:
        api_key = sys.argv[1]
    
    if not api_key:
        print("Usage: python3 test_gemini_live_full.py <API_KEY>")
        sys.exit(1)
    
    log(f"API Key: {api_key[:10]}...{api_key[-4:]}")
    
    await test_with_system_instruction(api_key)

if __name__ == "__main__":
    asyncio.run(main())
