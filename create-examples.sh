#!/usr/bin/env bash

#base_url="http://127.0.0.1:7678"
base_url="https://cr.iou.re"

create() {
    local alias="$1"
    local status_code="$2"
    local ctype="$3"
    local content="${4}"
    local jsondata
    jsondata=$(jq -cn --arg a "$alias" --arg s "$status_code" \
        --arg c "$ctype" --arg code "$content" \
        '{alias: $a, status_code: $s, ctype: $c, content: $code}')
    status=$(curl -o /dev/null -w '%{http_code}\n' -s -XPOST -d "${jsondata}" -H'Content-Type: application/json' "${base_url}/v1/customresponse")
    if [[ "$status" != "201" ]]; then
        echo "Failed: $status - $alias"
    fi
}

create "xml" 200 "application/xml" '<?xml version="1.0" encoding="UTF-8"?>
<email>
  <to>Maria</to>
  <from>Manuel</from>
  <heading>Remember</heading>
  <body>Remember to piojitos!</body>
</email>'

create "json" 200 "application/json" '{
  "age": "24 years old",
  "home": {
    "country": "Spain",
    "address": "229 example street"
  },
  "friends": [
    "Ruthe, Merrill",
    "Casey, Kordula",
    "Jolene, Felipa",
    "Shell, Jemie",
    "Bernadette, Vanny"
  ]
}'

create "html" 200 "text/html" '<h3>Lorem Ipsum</h3>
<p>
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam fermentum turpis est, non pulvinar nisl congue ultrices. Fusce et varius libero. In a nulla porttitor, dignissim ex sit amet, bibendum eros. In hac habitasse platea dictumst. Aliquam varius tempus purus eu vestibulum. Phasellus ac maximus lectus. Quisque vestibulum accumsan ante ut gravida. Nam ut mauris nec mi aliquam maximus. Sed quam mauris, consequat sed placerat vel, efficitur sit amet lectus. Nam arcu libero, auctor id finibus nec, mollis vel lacus. Sed eu sodales nisl, nec pharetra justo. Morbi vulputate ornare pharetra.
</p>
<p>
Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In eu nibh massa. Pellentesque aliquam non massa et convallis. Morbi molestie aliquam luctus. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Fusce commodo quis metus ut lobortis. Nunc semper ipsum erat, a congue lacus convallis quis. Proin facilisis id sapien ut efficitur. Morbi cursus at lorem quis dignissim. Nulla ac auctor ipsum. Phasellus iaculis lorem erat, eget pharetra est posuere sed. Integer erat felis, efficitur non libero at, dapibus tempus ante. Nulla dolor orci, scelerisque at mauris vel, ullamcorper elementum mi. Aenean efficitur venenatis turpis id varius.
</p>
<p>
Nunc pretium dui felis, eu varius velit auctor vel. Vivamus in leo eu urna viverra sodales ac aliquet leo. Integer nec purus ac nunc elementum tristique. Donec lectus augue, tristique vel lobortis id, rhoncus ac massa. Mauris nunc nisl, molestie nec lobortis eu, euismod quis dolor. Aliquam a orci diam. Maecenas posuere erat laoreet lectus congue fringilla.
</p>
<p>
Aenean condimentum ultricies diam. Maecenas ullamcorper elementum magna, nec pretium erat tristique id. Sed aliquam nunc justo, nec vehicula leo congue eu. Vestibulum maximus turpis et metus placerat scelerisque. Vivamus pulvinar dignissim metus. Mauris finibus neque vel orci sollicitudin, vel commodo nisi scelerisque. Ut elit mi, vestibulum eu neque posuere, molestie tincidunt odio. Phasellus accumsan vulputate libero elementum gravida. Phasellus malesuada lectus ac felis vestibulum, eget imperdiet ipsum tincidunt. Curabitur pellentesque hendrerit sodales. Morbi eu bibendum odio.
</p>
<p>
Phasellus tellus lacus, accumsan in vehicula maximus, mattis in eros. Sed eget quam non mi mollis laoreet nec at ligula. Quisque condimentum ex vitae risus finibus, a dignissim mauris maximus. Mauris consequat felis quis facilisis luctus. Praesent vulputate, metus ac consectetur mollis, velit lacus mattis eros, mollis malesuada arcu turpis at magna. Morbi mollis pretium odio, ac convallis tellus maximus id. Curabitur congue magna orci, at varius lacus convallis ut. Aliquam erat volutpat. Nulla facilisi.
</p>'

create "200 - OK" 200 "text/html" '
<h1>200 - OK</h1>
<h3>Request fulfilled, document follows</h3>
'

create "201 - Created" 201 "text/html" '
<h1>201 - Created</h1>
<h3>Document created, URL follows</h3>
'

create "202 - Accepted" 202 "text/html" '
<h1>202 - Accepted</h1>
<h3>Request accepted, processing continues off-line</h3>
'

create "204 - No Content" 204 "text/html" '
<h1>204 - No Content</h1>
<h3>Request fulfilled, nothing follows</h3>
'

create "206 - Partial Content" 206 "text/html" '
<h1>206 - Partial Content</h1>
<h3>Partial content follows</h3>
'

create "301 - Moved Permanently" 301 "text/html" '
<h1>301 - Moved Permanently</h1>
<h3>Object moved permanently -- see URI list</h3>
'

create "302 - Found" 302 "text/html" '
<h1>302 - Found</h1>
<h3>Object moved temporarily -- see URI list</h3>
'

create "304 - Not Modified" 304 "text/html" '
<h1>304 - Not Modified</h1>
<h3>Document has not changed since given time</h3>
'

create "307 - Temporary Redirect" 307 "text/html" '
<h1>307 - Temporary Redirect</h1>
<h3>Object moved temporarily -- see URI list</h3>
'

create "308 - Permanent Redirect" 308 "text/html" '
<h1>308 - Permanent Redirect</h1>
<h3>Object moved permanently -- see URI list</h3>
'

create "400 - Bad Request" 400 "text/html" '
<h1>400 - Bad Request</h1>
<h3>Bad request syntax or unsupported method</h3>
'

create "401 - Unauthorized" 401 "text/html" '
<h1>401 - Unauthorized</h1>
<h3>No permission -- see authorization schemes</h3>
'

create "403 - Forbidden" 403 "text/html" '
<h1>403 - Forbidden</h1>
<h3>Request forbidden -- authorization will not help</h3>
'

create "404 - Not Found" 404 "text/html" '
<h1>404 - Not Found</h1>
<h3>Nothing matches the given URI</h3>
'

create "405 - Method Not Allowed" 405 "text/html" '
<h1>405 - Method Not Allowed</h1>
<h3>Specified method is invalid for this resource</h3>
'

create "410 - Gone" 410 "text/html" '
<h1>410 - Gone</h1>
<h3>URI no longer exists and has been permanently removed</h3>
'

create "429 - Too Many Requests" 429 "text/html" '
<h1>429 - Too Many Requests</h1>
<h3>The user has sent too many requests in a given amount of time ("rate limiting")</h3>
'

create "500 - Internal Server Error" 500 "text/html" '
<h1>500 - Internal Server Error</h1>
<h3>Server got itself in trouble</h3>
'

create "502 - Bad Gateway" 502 "text/html" '
<h1>502 - Bad Gateway</h1>
<h3>Invalid responses from another server/proxy</h3>
'

create "503 - Service Unavailable" 503 "text/html" '
<h1>503 - Service Unavailable</h1>
<h3>The server cannot process the request due to a high load</h3>
'

create "504 - Gateway Timeout" 504 "text/html" '
<h1>504 - Gateway Timeout</h1>
<h3>The gateway server did not receive a timely response</h3>
'
