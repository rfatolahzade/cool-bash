# Log-Scout 🕵️‍♂️

**Professional Log Analyzer for Security Monitoring and IP Analysis**

Log-Scout is a powerful bash script designed to analyze various types of server logs and provide detailed insights into client behavior, helping system administrators and security professionals identify potential threats and monitor server performance.

> **🎯 Note**: While Log-Scout can be adapted for different log formats (Apache, HAProxy, etc.), the current version is specifically optimized for **Nginx logs** with the standard combined log format. For other log types, minor script modifications may be required to correctly identify IP addresses, response codes, and other fields.

> **💡 CDN Tip**: If your CDN (Cloudflare, CloudFront, etc.) provides analytics with real client IPs and request counts, consider using that data first for better accuracy. CDN logs often show the actual client IPs rather than the CDN's IP addresses.

## 🚀 Features

- **IP Request Analysis**: Identify which IPs are making the most requests
- **Detailed URL Breakdown**: See exactly which endpoints each IP is accessing
- **Performance Monitoring**: Track response times and status codes per URL
- **Top N Filtering**: Focus on the most active IPs with configurable limits
- **Pattern Filtering**: Filter logs by specific URL patterns (e.g., `/api/`)
- **Color-Coded Output**: Easy-to-read results with status code coloring
- **CIS Compliant**: Built with security best practices in mind

## 📋 Sample Usage

```bash
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

## 📝 Log Format Compatibility

**Default Supported Format (Nginx Combined):**
```bash
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" $request_time';
```
And as You could see:
```bash

**Field Mapping:**
- IP Address: `$1` (first field)    -$remote_addr
- Request: `$7` (seventh field)     -$request
- Status Code: `$9` (ninth field)   -$status
- Response Time: `$NF` (last field) -request_time

**For Other Log Formats:**
- **Apache**: Usually compatible with minimal changes
- **HAProxy**: May require field position adjustments
- **Custom Formats**: Modify AWK field references in the script

To adapt for different log formats, identify the correct field positions for:
1. Client IP address
2. Requested URL/endpoint
3. HTTP status code
4. Response time (if available)
```

| CIS Control,Implementation  |  Status |
|---     |---    |
| Ensure ServerTokens is set to Prod or Lower,server_tokens off;,| ✅ Compliant
| Ensure HTTP server logging is enabled,access_log and error_log directives,| ✅ Compliant
| Ensure HTTP server redirects are configured properly,HTTPS redirect servers,| ✅ Compliant
| Ensure HTTP server request limits are configured,limit_req_zone directives,| ✅ Compliant
| Ensure HTTP server modules are limited,Minimal module usage in config,| ✅ Compliant
| Ensure HTTP server SSL/TLS is configured properly,"SSL protocols, ciphers, session settings",| ✅ Compliant
| Ensure HTTP server OCSP stapling is enabled,ssl_stapling directives,| ✅ Compliant
| Ensure HTTP server header restrictions are configured,Security headers implementation,| ✅ Compliant
| Ensure HTTP server caching is configured properly,Static asset caching,| ✅ Compliant
| Ensure HTTP server file access is restricted,File extension restrictions,| ✅ Compliant
| Ensure HTTP server directory restrictions are configured,.well-known directory access,| ✅ Compliant
| Ensure HTTP server default server is configured,Default server block,| ✅ Compliant



📈 Use Cases 

    - Security Auditing: Identify potential brute force attempts or scanning
    - Performance Optimization: Find slow endpoints and heavy users
    - Traffic Analysis: Understand user behavior and popular content
    - Incident Response: Quickly analyze logs during security incidents
    - Capacity Planning: Monitor request patterns for resource allocation
     


🚨 Security Benefits 

    - Quick identification of suspicious IP activity
    - Detection of unusual request patterns
    - Monitoring of API endpoint usage
    - Performance impact analysis of specific clients
    - Compliance reporting with detailed logs
     
