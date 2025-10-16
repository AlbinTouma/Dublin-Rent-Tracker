import sys
import json
import pandas as pd

with open("listings.json") as f:
    data = json.load(f)

print(data)
