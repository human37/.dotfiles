#!/usr/bin/env python3

import sys
from urllib.parse import quote

def url_encode(string):
    return quote(string)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: url_encode.py <string_to_encode>")
        sys.exit(1)
    
    string_to_encode = sys.argv[1]
    encoded_string = url_encode(string_to_encode)
    print(encoded_string)
