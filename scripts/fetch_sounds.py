import subprocess
import json
import os
import sys

# Ensure correct path
ASSETS_DIR = "assets/sounds"
if not os.path.exists(ASSETS_DIR):
    os.makedirs(ASSETS_DIR)

SOUNDS = [
    {
        "file": "sign.mp3",
        "search": "wax seal stamp sound effect royalty free",
        "max_duration": 10,
        "desc": "Ratification Ritual seal stamp"
    },
    {
        "file": "complete.mp3",
        "search": "achievement sound effect gentle",
        "max_duration": 10,
        "desc": "Treaty/habit completion"
    },
    {
        "file": "recover.mp3",
        "search": "singing bowl single strike",
        "max_duration": 15,
        "desc": "Recovery state transition"
    },
    {
        "file": "clockwork.mp3",
        "search": "pocket watch ticking loop",
        "max_duration": 60,
        "desc": "3-second countdown ticking"
    },
    {
        "file": "thud.mp3",
        "search": "gavel sound effect",
        "max_duration": 5,
        "desc": "Final seal impact"
    },
    {
        "file": "ambience.mp3",
        "search": "dark ambient background loop meditation",
        "max_duration": 300,
        "desc": "Council Chamber background"
    }
]

TRUSTED_CHANNELS = [
    "Free Sound Effects",
    "Pixabay",
    "Epidemic Sound",
    "ZapSplat", 
    "Audio Library",
    "Sound Effects"
]

def get_candidates(query, limit=10):
    cmd = [
        "yt-dlp",
        "--dump-json",
        "--default-search", f"ytsearch{limit}",
        "--no-playlist",
        query
    ]
    # We DO NOT use --flat-playlist because we need subscriber counts and duration which might require resolving
    # However, resolving 10 items might be slow. 
    # Let's try --flat-playlist first? No, --flat-playlist doesn't give sub count.
    # We'll just fetch full info for top 5 to be safe and fast enough.
    cmd = [
        "yt-dlp",
        "--dump-json",
        f"ytsearch5:{query}"
    ]
    
    print(f"Running search: {query}...")
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error searching: {e}")
        return []

    candidates = []
    for line in result.stdout.strip().split('\n'):
        if not line: continue
        try:
            data = json.loads(line)
            candidates.append(data)
        except json.JSONDecodeError:
            continue
    return candidates

def score_candidate(candidate, sound_def):
    score = 0
    title = candidate.get('title', '')
    uploader = candidate.get('uploader', '')
    channel = candidate.get('channel', '') or uploader
    subs = candidate.get('channel_follower_count', 0)
    duration = candidate.get('duration', 999)
    
    # 1. Trusted Channel
    is_trusted = any(tc.lower() in channel.lower() for tc in TRUSTED_CHANNELS)
    if is_trusted:
        score += 20
        print(f"  [+] Trusted Channel: {channel}")
    
    # 2. Subscriber Count constraint (>100K) if not explicitly trusted
    if subs and subs > 100000:
        score += 10
        print(f"  [+] High Subs: {subs}")
    elif not is_trusted and (subs is None or subs < 10000):
        # Strict penalty for low subs if not trusted list
        print(f"  [-] Low Subs: {subs} ({channel})")
        return -1 

    # 3. Duration match
    if duration > sound_def['max_duration'] * 3: # Allow wiggle room for intros
        print(f"  [-] Too long: {duration}s")
        return -1
    else:
        score += 5
        
    # 4. "Royalty Free" or "No Copyright"
    if "royalty free" in title.lower() or "no copyright" in title.lower():
        score += 5
        
    return score

def download_sound(url, filename):
    print(f"Downloading {url} to {filename}...")
    # remove existing placeholders
    target_path = os.path.join(ASSETS_DIR, filename)
    if os.path.exists(target_path):
        os.remove(target_path)
        
    cmd = [
        "yt-dlp",
        "-x", # Extract audio
        "--audio-format", "mp3",
        "--audio-quality", "128K",
        "-o", target_path,
        url
    ]
    subprocess.run(cmd, check=True)
    
    # Check file size
    if os.path.exists(target_path):
        size = os.path.getsize(target_path)
        print(f"Success! {filename} size: {size} bytes")
    else:
        print(f"Failed to create {filename}")

def main():
    print("Starting audio acquisition...")
    
    for sound in SOUNDS:
        print(f"\nProcessing: {sound['file']} ({sound['desc']})")
        candidates = get_candidates(sound['search'])
        
        best_candidate = None
        best_score = -1
        
        for cand in candidates:
            score = score_candidate(cand, sound)
            if score > best_score:
                best_score = score
                best_candidate = cand
        
        if best_candidate:
            print(f"Selected: {best_candidate.get('title')} from {best_candidate.get('uploader')} (Score: {best_score})")
            try:
                download_sound(best_candidate.get('webpage_url'), sound['file'])
            except Exception as e:
                print(f"Download failed: {e}")
        else:
            print(f"No suitable candidate found for {sound['file']}")

if __name__ == "__main__":
    main()
