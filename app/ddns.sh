#!/bin/sh

currentIP=$(curl -s ifconfig.me/all.json | jq -r ".ip_addr")

cloudflare() {
    curl -sSL --header "Content-Type: application/json" --header "Accept: application/json" --header "Authorization: Bearer $TOKEN" "$@"
}

# Check token
tokenStatus=$(cloudflare $CF_API/user/tokens/verify | jq -r ".result.status")
if [[ $tokenStatus == "active" ]]; then { 
    echo "Token is active"
    # Get zone id
    zoneID=$(cloudflare "$CF_API/zones?name=$DOMAIN" | jq -r ".result[0].id")

    # Check record Status
    record=$CNAME.$DOMAIN
    echo "Checking record status"
    recordStatus=$(cloudflare "$CF_API/zones/$zoneID/dns_records?type=A&name=$record" | jq '.result | length')
    if [[ $recordStatus -eq 0 ]]; then {
        echo "Record Does not exist, Creating now."
        curl -sSL --request POST "$CF_API/zones/$zoneID/dns_records" --header 'Content-Type: application/json' --header 'Accept: application/json' --header "Authorization: Bearer $TOKEN" -d "{\"type\": \"A\",\"name\":\"$CNAME\",\"content\":\"$currentIP\",\"proxied\":true,\"ttl\":1 }" > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then {
                echo "Record for $record Created with $currentIP"
        }
        fi
    }
    else {
        echo "Record exists, Checking if needs to be updated."
        recordContent=$(cloudflare "$CF_API/zones/$zoneID/dns_records?type=A&name=$record" | jq .result[0].content)
        localIP=$(curl -s ifconfig.me/all.json | jq  .ip_addr)
        if [ "$recordContent" == "$localIP" ]; then {
            echo "Record for $record is upto date, no need to be update($currentIP)."
        }
        else {
            recordID=$(cloudflare "$CF_API/zones/$zoneID/dns_records?type=A&name=$record" | jq -r '.result[0].id')
            curl -sSL --request PATCH "$CF_API/zones/$zoneID/dns_records/$recordID" --header 'Content-Type: application/json' --header 'Accept: application/json' --header "Authorization: Bearer $TOKEN" -d "{\"type\": \"A\",\"name\":\"$CNAME\",\"content\":\"$currentIP\",\"proxied\":true }" > /dev/null 2>&1
            if [[ $? -eq 0 ]]; then {
                echo "Record for $record updated with $currentIP"
            }
            fi
        }
        fi
    }
    fi
}
else {
    echo "Check the token"
}
fi
