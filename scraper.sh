#!/bin/bash
set -e

echo "Running scraper"

page=1
url="https://www.daft.ie/sharing/dublin?page=$page"


curl 'https://www.daft.ie/property-for-rent/dublin?page=1' \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: en-GB,en;q=0.9,en-US;q=0.8,sv;q=0.7,ro;q=0.6' \
  -H 'cache-control: no-cache' \
  -b 'NPS_215a2284_last_seen=1759871237301; _gcl_au=1.1.947977802.1759871237; _hjSessionUser_1177694=eyJpZCI6ImMzYTJhMzRjLTg3NTktNWRhNC05OWRlLTRiYjQ1NTEwMzU2MiIsImNyZWF0ZWQiOjE3NTk4NzEyMzc2NzQsImV4aXN0aW5nIjp0cnVlfQ==; _ga=GA1.1.1983816236.1759871238; _fbp=fb.1.1759871238057.735424336600460502; _hjDonePolls=1810453; cf_clearance=OiX58POgC31EancKUkHevNdezDUoteJo3piQ7TjZYzE-1760049581-1.2.1.1-HGnR.WagMa9HUABgE9zBppTQK2YFrm7OXaikLDe15eNp2SHk.abkyLTnRIOtHFwwh7cLHil10rKaq3FWUYVI76Qh.1KJbgGdPyNNI_KX_db_XH3_662vT46t_F.jDRPmIiwiMa6MQcAYP7AM949gmT2jogDQpFUxhdIcBrf11uqlj5hKg3nrt0C1b8Nu3TiF1t0iyx4T9XVaiWrs0QQwFbwvQQTIexUF8nFscgSWexI; cto_bundle=4Qu7vF9QRjZESE15WmZ2U0hUU2pVWjdwSWRDOWVVUEFRYVFGbWh3SEx6bklUWlZmY3dYa0RBeXNkMmdUOVNWd0hHNzc4YjBWOFJCUEpXOUljTEliYm5ITnU3aVhoM3lPbUJKZ053dUlkNzV5bXQ1RkpvbEhkbWZyTnhERWklMkJRbktXSjhTVEJLVjQyUEVCcG9UUTFLNmhKdVBydyUzRCUzRA; _hjSession_1177694=eyJpZCI6ImNhZjUwY2M0LTZmMmItNGZjZi1hZmQyLTI4MDFmODI4MGM1OCIsImMiOjE3NjAwNDk1ODMzMzIsInMiOjEsInIiOjAsInNiIjowLCJzciI6MCwic2UiOjAsImZzIjowLCJzcCI6MH0=; __gads=ID=10c1270ae8c70660:T=1759871238:RT=1760049583:S=ALNI_MbNy6THRHA3y5_QChOKEkNkqjV72A; __gpi=UID=000012479567c7ce:T=1759871238:RT=1760049583:S=ALNI_MaTZAYl86ptMvRJj1KTjwqEDDyyGg; __eoi=ID=f1026c1c6b91acb2:T=1759871238:RT=1760049583:S=AA-AfjZDFxuAPj7MnHT3gQFuTjM1; _conv_v=vi%3A1*sc%3A4*cs%3A1760049583*fs%3A1759871238*pv%3A19*exp%3A%7B%7D*seg%3A%7B%7D*ps%3A1759878687; _conv_s=sh%3A1760049583065-0.9945575444721959*si%3A4*pv%3A2; _ga_3SCE3PXHNT=GS2.1.s1760049583$o4$g1$t1760049594$j49$l0$h0' \
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
