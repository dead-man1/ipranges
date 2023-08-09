#!/bin/bash

# https://azure.microsoft.com/en-us/updates/service-tag-discovery-api-in-preview/
# https://docs.microsoft.com/en-us/microsoft-365/enterprise/urls-and-ip-address-ranges?view=o365-worldwide
# From: https://github.com/jensihnow/AzurePublicIPAddressRanges/blob/main/.github/workflows/main.yml

set -euo pipefail
set -x


# get from public ranges
download_and_parse() {
    URL="$(curl -s https://www.microsoft.com/en-us/download/confirmation.aspx?id=${1} | grep -o '<a href=['"'"'"][^"'"'"']*['"'"'"]' | grep ServiceTags_ | head -1 | sed -e 's/^<a href=["'"'"']//' -e 's/["'"'"']$//')"
    curl --connect-timeout 60 --retry 3 --retry-delay 15 -s "${URL}" > /tmp/microsoft.json
    jq '.values[] | [.properties] | .[].addressPrefixes[] | select(. != null)' -r /tmp/microsoft.json > /tmp/microsoft-all.txt

    # save ipv4
    grep -v ':' /tmp/microsoft-all.txt >> /tmp/microsoft-ipv4.txt

    # save ipv6
    grep ':' /tmp/microsoft-all.txt >> /tmp/microsoft-ipv6.txt
}

# Public cloud
download_and_parse "56519"
# US Gov
download_and_parse "57063"
# Germany
download_and_parse "57064"
# China
download_and_parse "57062"


# sort & uniq
sort -V /tmp/microsoft-ipv4.txt | uniq > microsoft/ipv4.txt
sort -V /tmp/microsoft-ipv6.txt | uniq > microsoft/ipv6.txt
