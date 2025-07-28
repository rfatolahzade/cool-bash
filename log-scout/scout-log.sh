#!/bin/bash

# Nginx Log Analyzer - Professional IP Analysis with Top N
# Version: 1.1

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}=== Nginx Log Professional IP Analyzer ===${NC}"
echo

# Get log file
read -p "Enter log file path: " log_file

if [[ ! -f "$log_file" ]]; then
    echo -e "${RED}Log file not found: $log_file${NC}"
    exit 1
fi

# Get URL filter
read -p "Enter URL pattern to filter (leave empty for all): " url_pattern

# Get top N count
read -p "Show top N IPs? Enter number (default 10, 0 for all): " top_count
top_count=${top_count:-10}

echo
echo -e "${BLUE}Analyzing logs from: $log_file${NC}"
if [[ -n "$url_pattern" ]]; then
    echo -e "${BLUE}Filtering by URL pattern: $url_pattern${NC}"
fi
if [[ $top_count -gt 0 ]]; then
    echo -e "${BLUE}Showing top $top_count IPs by request count${NC}"
else
    echo -e "${BLUE}Showing all IPs${NC}"
fi
echo "================================================================================"

# Create temporary files
temp_file=$(mktemp)
ip_summary_file=$(mktemp)

# Detailed analysis
if [[ -n "$url_pattern" ]]; then
    awk -v pattern="$url_pattern" '
    $7 ~ pattern {
        ip = $1
        url = $7
        status = $9
        response_time = $NF
        
        # IP level stats
        ip_count[ip]++
        ip_total_time[ip] += response_time
        
        # URL level stats per IP
        key = ip ":" url ":" status
        url_count[key]++
        url_total_time[key] += response_time
    }
    END {
        # Output URL details
        for (key in url_count) {
            split(key, parts, ":")
            ip = parts[1]
            url = parts[2]
            status = parts[3]
            count = url_count[key]
            avg_time = url_total_time[key] / count
            
            printf "%s|%s|%d|%s|%d|%.3f|%s\n", ip, ip, ip_count[ip], status, count, avg_time, url > "'$temp_file'"
        }
        
        # Output IP summary lines
        for (ip in ip_count) {
            avg_time = ip_total_time[ip] / ip_count[ip]
            printf "%s|%d|%.3f\n", ip, ip_count[ip], avg_time > "'$ip_summary_file'"
        }
    }
    ' "$log_file"
else
    awk '
    {
        ip = $1
        url = $7
        status = $9
        response_time = $NF
        
        # IP level stats
        ip_count[ip]++
        ip_total_time[ip] += response_time
        
        # URL level stats per IP
        key = ip ":" url ":" status
        url_count[key]++
        url_total_time[key] += response_time
    }
    END {
        # Output URL details
        for (key in url_count) {
            split(key, parts, ":")
            ip = parts[1]
            url = parts[2]
            status = parts[3]
            count = url_count[key]
            avg_time = url_total_time[key] / count
            
            printf "%s|%s|%d|%s|%d|%.3f|%s\n", ip, ip, ip_count[ip], status, count, avg_time, url > "'$temp_file'"
        }
        
        # Output IP summary lines
        for (ip in ip_count) {
            avg_time = ip_total_time[ip] / ip_count[ip]
            printf "%s|%d|%.3f\n", ip, ip_count[ip], avg_time > "'$ip_summary_file'"
        }
    }
    ' "$log_file"
fi

# Display results
echo -e "${BOLD}${YELLOW}IP ADDRESS      TOTAL   AVG TIME${NC}"
echo -e "${BOLD}${YELLOW}--------------- ------  --------${NC}"

# Sort IPs by request count and limit to top N if specified
if [[ $top_count -gt 0 ]]; then
    sorted_ips=$(sort -t'|' -k2 -nr "$ip_summary_file" | head -n "$top_count")
else
    sorted_ips=$(sort -t'|' -k2 -nr "$ip_summary_file")
fi

echo "$sorted_ips" | while IFS='|' read -r ip total_req avg_time; do
    if [[ -n "$ip" ]]; then
        # IP Summary line
        printf "${CYAN}%-15s %6s  %8.3fs${NC}\n" "$ip" "$total_req" "$avg_time"
        echo -e "  ${BOLD}Status  Count   Avg Time   URL${NC}"
        echo -e "  ${BOLD}------  -----   --------   ---${NC}"
        
        # Show URL details for this IP, sorted by count (descending)
        awk -F'|' -v target_ip="$ip" '$1 == target_ip {print $4"|"$5"|"$6"|"$7}' "$temp_file" | \
        sort -t'|' -k2 -nr | while IFS='|' read -r status count avg_time url; do
            if [[ -n "$status" ]]; then
                color=""
                if [[ "$status" =~ ^2 ]]; then
                    color="${GREEN}"
                elif [[ "$status" =~ ^3 ]]; then
                    color="${BLUE}"
                elif [[ "$status" =~ ^4 ]]; then
                    color="${YELLOW}"
                elif [[ "$status" =~ ^5 ]]; then
                    color="${RED}"
                fi
                printf "  ${color}%6s  %5s   %7.3fs   %s${NC}\n" "$status" "$count" "$avg_time" "$url"
            fi
        done
        echo ""
    fi
done

# Clean up
rm -f "$temp_file" "$ip_summary_file"

echo "================================================================================"
echo -e "${GREEN}${BOLD}Analysis complete.${NC}"
