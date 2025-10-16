#!/bin/bash
set -e

echo "Running scraper"

page=1
url="https://www.daft.ie/sharing/dublin?page=$page"


curl 'https://www.daft.ie/property-for-rent/dublin?page=1' \
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
