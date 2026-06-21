#!/bin/sh
set -e

VERSION=$(cat /VERSION)
echo "macs-test-suite starting — version ${VERSION}"

cat > /tmp/respond.sh << SCRIPT
#!/bin/sh
BODY="{\"status\":\"ok\",\"version\":\"${VERSION}\"}"
printf "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s" \
    "\${#BODY}" "\$BODY"
SCRIPT
chmod +x /tmp/respond.sh

exec nc -lk -p 8080 -e /tmp/respond.sh
