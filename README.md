# infomaniak-api-dyndns

The purpose of this container is to update DNS zone records using Infomaniak's DynDNS API (https://www.infomaniak.com/fr/support/faq/2376/utiliser-dyndns-par-api-infomaniak) with your WAN IP.

This image is extremely lightweight  (Alpine Linux based) and has very few dependencies. The actual DNS update program is coded in shell script only.

You need to create a new DynDNS entry in Infomaniak manager, as well as credentials for the update.
All domain managed by this container will be updated using the same credentials.

## Configuration
Mandatory variables:
* DYNDNS_USER : your DynDNS username
* DYNDNS_PASSWORD: your DynDNS password
* RECORD_LIST: DNS records to update separated by ";"

Optional variables :
* REFRESH_INTERVAL: Delay between updates in seconds (default: 10mn)
* SET_IPV4: Update A record (default: yes)
* SET_IPV6: Update AAAA record (default: no)

## Examples
The easiest way to run infomaniak-api-dyndns is simply to *docker run* it from a computer in your network, leaving it running in the background with all the default settings.
```sh
docker run -d \
	-e "DYNDNS_USER=<YOUR_DYNDNS_USER>" \
	-e "DYNDNS_PASSWORD=<YOUR_DYNDNS_PASSWORD>" \
	-e "RECORD_LIST=blog.example.com;www.example.com;example.com" \
	jbbodart/infomaniak-api-dyndns
```
This will update **blog.example.com**, **www.example.com**, and **example.com** with your internet-facing IP (IPv4) every 10 minutes

An equivalent setup using docker-compose could look like this:  
**docker-compose.yml**
```yml
version: '3.7'
...
    services:
    ...
        dyndns:
            image: jbbodart/infomaniak-api-dyndns
            restart: unless-stopped
            env_file:
                - "dyndns.env"
```

**dyndns.env**
```properties
DYNDNS_USER=<YOUR_DYNDNS_USER>
DYNDNS_PASSWORD=<YOUR_DYNDNS_PASSWORD>
RECORD_LIST=blog.example.com;www.example.com;example.com
REFRESH_INTERVAL=3600
SET_IPV4=yes
SET_IPV6=no

```

If you want to use docker-compose.yaml, just copy `dyndns.env.example` to `dyndns.env` adapt the value and run `docker-compose up -d --build --pull`, then check if it works via `docker compose logs -f dyndns`.
