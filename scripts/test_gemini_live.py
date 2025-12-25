#!/usr/bin/env python3
"""
Gemini Live API WebSocket Test Script
Phase 34.4g: Diagnose connection issues

This script tests the WebSocket connection to Gemini Live API
with different model names to identify which one works.

Usage:
    python3 test_gemini_live.py <API_KEY>
    
Or set environment variable:
    export GEMINI_API_KEY=your_key
    python3 test_gemini_live.py
"""

import asyncio
import json
import os
import sys
import time
from datetime import datetime

try:
    import websockets
except ImportError:
    print("Installing websockets...")
    os.system("pip3 install websockets")
    import websockets

# Model names to test
MODELS_TO_TEST = [
    # From Google AI Studio rate limits (user's actual quota)
    "gemini-2.5-flash-native-audio-dialog",
    # From official changelog (Dec 12, 2025)
    "gemini-2.5-flash-native-audio-preview-12-2025",
    # Older model (may be shut down)
    "gemini-2.5-flash-native-audio-preview-09-2025",
]

# WebSocket endpoint
WS_ENDPOINT = "wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent"

def log(msg):
    timestamp = datetime.now().strftime("%H:%M:%S.%f")[:-3]
    print(f"[{timestamp}] {msg}")

async def test_model(api_key: str, model_name: str, timeout: int = 15):
    """Test a single model name"""
    log(f"\n{'='*60}")
    log(f"TESTING MODEL: {model_name}")
    log(f"{'='*60}")
    
    url = f"{WS_ENDPOINT}?key={api_key}"
    log(f"URL: {WS_ENDPOINT}?key=***MASKED***")
    
    # Minimal setup message (only required fields)
    setup_message = {
        "setup": {
            "model": f"models/{model_name}",
            "generationConfig": {
                "responseModalities": ["AUDIO"],
                "speechConfig": {
                    "voiceConfig": {
                        "prebuiltVoiceConfig": {
                            "voiceName": "Kore"
                        }
                    }
                }
            }
        }
    }
    
    log(f"Setup message: {json.dumps(setup_message, indent=2)}")
    
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
                response = await asyncio.wait_for(ws.recv(), timeout=timeout)
                elapsed = (time.time() - start_time) * 1000
                
                data = json.loads(response)
                log(f"📨 Response received ({elapsed:.0f}ms)")
                log(f"Response: {json.dumps(data, indent=2)[:500]}")
                
                if "setupComplete" in data:
                    log(f"✅ SUCCESS! Model '{model_name}' works!")
                    return True, model_name, None
                elif "error" in data:
                    error_msg = data.get("error", {}).get("message", str(data))
                    log(f"❌ Error from server: {error_msg}")
                    return False, model_name, error_msg
                else:
                    log(f"⚠️ Unexpected response: {data}")
                    return False, model_name, f"Unexpected: {data}"
                    
            except asyncio.TimeoutError:
                elapsed = (time.time() - start_time) * 1000
                log(f"❌ TIMEOUT after {elapsed:.0f}ms - no setupComplete received")
                return False, model_name, "TIMEOUT - no setupComplete"
                
    except websockets.exceptions.InvalidStatusCode as e:
        log(f"❌ HTTP Error: {e.status_code}")
        return False, model_name, f"HTTP {e.status_code}"
    except Exception as e:
        log(f"❌ Connection error: {type(e).__name__}: {e}")
        return False, model_name, str(e)

async def main():
    # Get API key
    api_key = os.environ.get("GEMINI_API_KEY")
    if len(sys.argv) > 1:
        api_key = sys.argv[1]
    
    if not api_key:
        print("Usage: python3 test_gemini_live.py <API_KEY>")
        print("Or set: export GEMINI_API_KEY=your_key")
        sys.exit(1)
    
    log(f"API Key: {api_key[:10]}...{api_key[-4:]}")
    log(f"Endpoint: {WS_ENDPOINT}")
    
    results = []
    
    for model in MODELS_TO_TEST:
        success, name, error = await test_model(api_key, model)
        results.append((success, name, error))
        await asyncio.sleep(1)  # Brief pause between tests
    
    # Summary
    log(f"\n{'='*60}")
    log("SUMMARY")
    log(f"{'='*60}")
    
    working_models = []
    for success, name, error in results:
        status = "✅ WORKS" if success else f"❌ FAILED: {error}"
        log(f"  {name}: {status}")
        if success:
            working_models.append(name)
    
    if working_models:
        log(f"\n🎉 Working model(s): {', '.join(working_models)}")
        log(f"\nUpdate ai_model_config.dart to use: {working_models[0]}")
    else:
        log("\n❌ No models worked. Possible issues:")
        log("  1. API key doesn't have Live API access")
        log("  2. Regional restriction")
        log("  3. All model names are wrong")

if __name__ == "__main__":
    asyncio.run(main())
