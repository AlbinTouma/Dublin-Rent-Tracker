#!/bin/bash

# I want to collect listings from daft on a daily basis and update the json file. I don't want duplicates in the data.
# I need the script to run and collect data from all pages if there's no file and only fetch the first page if there's data already.
# Page one is updated a few times per hour so there's always going to be one or more listings on it. When all_exist returns true is therefore likely on page 2 or 3.


set -euo pipefail
echo "Running scraper"

OUTPUT_FILE="output.json"
TEMP_FILE=(mktemp)
echo "[]" > "$TEMP_FILE" 

# Page starts at 1 else 404
PAGE=1

get_daft(){
  # get_daft curls the page and returns the json array []
  local page="$1"

  curl -s "https://www.daft.ie/sharing/dublin?page=${page}" \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-GB,en;q=0.9,en-US;q=0.8,sv;q=0.7,ro;q=0.6' \
    -H 'cache-control: no-cache' \
    -H 'pragma: no-cache' \
    -H 'priority: u=0, i' \
    -H 'sec-ch-ua: "Google Chrome";v="141", "Not?A_Brand";v="8", "Chromium";v="141"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Linux"' \
    -H 'sec-fetch-dest: document' \
    -H 'sec-fetch-mode: navigate' \
    -H 'sec-fetch-site: same-origin' \
    -H 'sec-fetch-user: ?1' \
    -H 'upgrade-insecure-requests: 1' \
    -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36' \
    |grep -Pzo '(?s)(?<=<script id="__NEXT_DATA__" type="application/json" crossorigin="anonymous">).*?(?=</script>)'  |
    jq '[
    .props.pageProps.listings[] | delpaths([
    ["listing", "image"], 
    ["listing", "prs"], 
    ["listing", "media"], 
    ["listing", "seller", "profileImage"], 
    ["listing", "seller", "profileRoundedImage"], 
    ["listing", "seller", "squareLogo"], 
    ["listing", "seller", "standardLogo"], 
    ["listing", "pageBranding"]
    ])
    ]' 

}

check_id(){
  #Opens output.json and checks if id present. If id new it saves the listing to temp.
  local new_listings="$1"
  local existing_ids="$2"
  local TEMP_FILE="$3"
  local all_exist=true

  while read -r listing; do
    id=$(echo "$listing" | jq -r '.listing.id')
    
    if grep -Fxq "$id" <<< "$existing_ids"; then
      echo "id exists $id"
    else
      echo "$listing" | jq '{title: .listing.title, id: .listing.id}'
      jq -c ". + [$listing]" "$TEMP_FILE" > "$TEMP_FILE.tmp"
      mv "$TEMP_FILE.tmp" "$TEMP_FILE"
      all_exist=false
    fi

  done < <(echo "$new_listings" | jq -c '.[]') 

  $all_exist && return 0 || return 1

}

while true; 
do
  echo "Scraping page $PAGE"

  new_listings="$(get_daft "$PAGE")"

  if [ -z "$new_listings" ] || [ "$new_listings" = "[]" ]; then
    echo "No listings found or end reached."
    break
  fi

  existing_ids=$(jq -r '.[].listing.id' "$OUTPUT_FILE" | sort -u)

  if check_id "$new_listings" "$existing_ids" "$TEMP_FILE"; then
    echo "All IDs on page already exist. Stopping early".
    break
  else
    echo "New listings on $PAGE"
  fi


  ((PAGE++))


done

echo "Merging data and writing to output.json"
jq -s 'add | unique_by(.listing.id)' "$OUTPUT_FILE" "$TEMP_FILE" > "$OUTPUT_FILE.tmp"
mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
echo "Scraping completed"

sqlite-utils insert daft.db sharing output.json --pk=id