#!/usr/bin/env python3

import requests
import json
import time
from datetime import datetime
from pathlib import Path
import sys

# --- CONFIGURATION ---
CITY = "Johannesburg"
COUNTRY = "South Africa"
METHOD = 3 
CACHE_FILE = Path.home() / ".cache" / "prayer_times.json"

# Fixed width to prevent the Waybar module from changing size
VISIBLE_WIDTH = 25  
# ---------------------

def fetch_prayer_times():
    try:
        url = f"http://api.aladhan.com/v1/timingsByCity?city={CITY}&country={COUNTRY}&method={METHOD}"
        response = requests.get(url, timeout=5)
        data = response.json()
        if data.get('code') == 200:
            CACHE_FILE.parent.mkdir(parents=True, exist_ok=True)
            with open(CACHE_FILE, 'w') as f:
                json.dump(data, f)
            return data['data']['timings']
    except Exception:
        return None

def get_cached_times():
    try:
        if CACHE_FILE.exists():
            with open(CACHE_FILE) as f:
                data = json.load(f)
                return data['data']['timings']
    except Exception:
        return None

def format_output(prayer_times):
    prayers_order = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']
    
    # Create the full string to be scrolled without the icon
    prayer_list = [f"{p}: {prayer_times[p]}" for p in prayers_order if p in prayer_times]
    # Added extra padding at the start and end for a smoother loop
    full_string = "  |  ".join(prayer_list) + "  |  "
    
    # --- SLIDING LOGIC ---
    # Moves 1 character per second based on the Unix timestamp
    current_tick = int(time.time())
    content_len = len(full_string)
    shift = current_tick % content_len
    
    # Slice and wrap the string
    scrolling_content = (full_string[shift:] + full_string[:shift])
    
    # Force the display to be exactly VISIBLE_WIDTH characters
    display_text = scrolling_content[:VISIBLE_WIDTH].ljust(VISIBLE_WIDTH)
    
    # Tooltip remains a standard list for easy reading
    tooltip_text = "\n".join([f"{p}: {prayer_times[p]}" for p in prayers_order])
    
    return {
        'text': display_text,
        'tooltip': f"Today's Schedule:\n{tooltip_text}",
        'class': 'prayer-times'
    }

def main():
    prayer_times = fetch_prayer_times() or get_cached_times()
    
    if not prayer_times:
        error_msg = "No Data".center(VISIBLE_WIDTH)
        print(json.dumps({'text': error_msg, 'class': 'error'}))
        return
    
    print(json.dumps(format_output(prayer_times)))

if __name__ == "__main__":
    main()
