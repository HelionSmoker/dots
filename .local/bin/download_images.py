#!/bin/python3

import requests
import sys
import time
from concurrent.futures import ThreadPoolExecutor

# Determine the filename from the command line argument or use a default
filename = sys.argv[1] if len(sys.argv) > 1 else "urls.txt"

# Function to download an image
def download_image(url):
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raises an HTTPError for bad responses

        # Check if the content type is an image
        if 'image' in response.headers['Content-Type']:
            # Write the content of the response to a file
            with open(url.split('/')[-1], 'wb') as f:
                f.write(response.content)
            print(f"Downloaded {url}")
        else:
            print(f"Skipped non-image file at {url}")
    except requests.RequestException as e:
        print(f"Failed to download {url}: {e}")

# Function to read URLs from a file and manage download rate
def download_images_from_file(filename):
    with open(filename, 'r') as file:
        urls = file.readlines()

    # Remove any extraneous whitespace
    urls = [url.strip() for url in urls if url.strip()]

    # Setup ThreadPoolExecutor to manage concurrency
    with ThreadPoolExecutor(max_workers=3) as executor:
        # Setup a simple rate limiter, 3 requests per second
        for i in range(0, len(urls), 3):
            batch = urls[i:i+3]
            executor.map(download_image, batch)
            time.sleep(1)  # Pause the loop to maintain rate limiting

if __name__ == "__main__":
    download_images_from_file(filename)
