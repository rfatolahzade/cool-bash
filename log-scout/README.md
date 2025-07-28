CIS Control,Implementation,Status
Ensure ServerTokens is set to Prod or Lower,server_tokens off;,✅ Compliant
Ensure HTTP server logging is enabled,access_log and error_log directives,✅ Compliant
Ensure HTTP server redirects are configured properly,HTTPS redirect servers,✅ Compliant
Ensure HTTP server request limits are configured,limit_req_zone directives,✅ Compliant
Ensure HTTP server modules are limited,Minimal module usage in config,✅ Compliant
Ensure HTTP server SSL/TLS is configured properly,"SSL protocols, ciphers, session settings",✅ Compliant
Ensure HTTP server OCSP stapling is enabled,ssl_stapling directives,✅ Compliant
Ensure HTTP server header restrictions are configured,Security headers implementation,✅ Compliant
Ensure HTTP server caching is configured properly,Static asset caching,✅ Compliant
Ensure HTTP server file access is restricted,File extension restrictions,✅ Compliant
Ensure HTTP server directory restrictions are configured,.well-known directory access,✅ Compliant
Ensure HTTP server default server is configured,Default server block,✅ Compliant

  Sample use:
```bash

root@Mad:~/cool-bash/log-scout# ./scout-log.sh
=== Nginx Log Professional IP Analyzer ===

Enter log file path: ~/cool-bash/log-scout/access.log
Log file not found: ~/cool-bash/log-scout/access.log
root@Mad:~/cool-bash/log-scout# ./scout-log.sh
root@Mad:~/cool-bash/log-scout# ./scout-log.sh
=== Nginx Log Professional IP Analyzer ===

Enter log file path: /root/cool-bash/log-scout/access.log
Enter URL pattern to filter (leave empty for all):
Show top N IPs? Enter number (default 10, 0 for all): 3

Analyzing logs from: /root/cool-bash/log-scout/access.log
Showing top 3 IPs by request count
================================================================================
IP ADDRESS      TOTAL   AVG TIME
--------------- ------  --------
203.0.113.45         9     0.025s
  Status  Count   Avg Time   URL
  ------  -----   --------   ---
     200      1     0.089s   /images/banner.jpg
     200      1     0.045s   /contact
     200      1     0.023s   /privacy
     200      1     0.023s   /js/app.js
     200      1     0.012s   /sitemap.xml
     200      1     0.012s   /images/logo.png
     200      1     0.008s   /
     200      1     0.007s   /favicon.ico
     200      1     0.006s   /robots.txt

192.168.1.100        8     0.137s
  Status  Count   Avg Time   URL
  ------  -----   --------   ---
     204      1     0.034s   /api/sessions
     201      1     0.078s   /api/comments
     200      1     0.298s   /api/orders
     200      1     0.180s   /api/users/123
     200      1     0.150s   /api/users
     200      1     0.145s   /api/notifications
     200      1     0.123s   /api/settings
     200      1     0.089s   /api/items/789

198.51.100.23        7     0.109s
  Status  Count   Avg Time   URL
  ------  -----   --------   ---
     200      1     0.234s   /api/products
     200      1     0.167s   /blog
     200      1     0.156s   /api/products/456
     200      1     0.089s   /shop
     200      1     0.067s   /cart
     200      1     0.034s   /about
     200      1     0.015s   /css/style.css

================================================================================
Analysis complete.
```

