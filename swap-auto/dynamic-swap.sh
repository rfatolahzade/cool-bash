#!/bin/bash

# Dynamic Swap Manager
# Creates swap file when memory usage > 80%
# Removes swap file when memory usage < 80%

# Configuration
SWAP_FILE="/swapfile_dynamic"
SWAP_SIZE_GB=4
MEMORY_THRESHOLD=80
CHECK_INTERVAL=37  # seconds

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a /var/log/dynamic-swap.log
}

# Check if script is running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_message "ERROR" "This script must be run as root"
        exit 1
    fi
}

# Get current memory usage percentage
get_memory_usage() {
    local mem_info=$(free | grep Mem)
    local total=$(echo $mem_info | awk '{print $2}')
    local used=$(echo $mem_info | awk '{print $3}')
    local percentage=$((used * 100 / total))
    echo $percentage
}

# Check if swap file exists
swap_exists() {
    if [[ -f "$SWAP_FILE" ]] && [[ $(swapon --show | grep "$SWAP_FILE" | wc -l) -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}

# Create swap file
create_swap() {
    log_message "INFO" "Creating ${SWAP_SIZE_GB}GB swap file..."
    
    # Check if swap file already exists
    if [[ -f "$SWAP_FILE" ]]; then
        log_message "WARN" "Swap file already exists"
        return 1
    fi
    
    # Create swap file
    if fallocate -l ${SWAP_SIZE_GB}G "$SWAP_FILE" 2>/dev/null; then
        log_message "INFO" "Swap file created successfully"
    else
        log_message "INFO" "fallocate failed, using dd method..."
        dd if=/dev/zero of="$SWAP_FILE" bs=1M count=$((SWAP_SIZE_GB * 1024)) 2>/dev/null
    fi
    
    # Set permissions
    chmod 600 "$SWAP_FILE"
    
    # Format as swap
    if mkswap "$SWAP_FILE" >/dev/null 2>&1; then
        log_message "INFO" "Swap file formatted successfully"
    else
        log_message "ERROR" "Failed to format swap file"
        rm -f "$SWAP_FILE"
        return 1
    fi
    
    # Enable swap
    if swapon "$SWAP_FILE" >/dev/null 2>&1; then
        log_message "INFO" "Swap file enabled successfully"
        return 0
    else
        log_message "ERROR" "Failed to enable swap file"
        rm -f "$SWAP_FILE"
        return 1
    fi
}

# Remove swap file
remove_swap() {
    log_message "INFO" "Removing swap file..."
    
    # Disable swap first
    if swapoff "$SWAP_FILE" >/dev/null 2>&1; then
        log_message "INFO" "Swap file disabled successfully"
    else
        log_message "WARN" "Failed to disable swap file (might not be active)"
    fi
    
    # Remove swap file
    if rm -f "$SWAP_FILE"; then
        log_message "INFO" "Swap file removed successfully"
        return 0
    else
        log_message "ERROR" "Failed to remove swap file"
        return 1
    fi
}

# Monitor memory and manage swap
monitor_memory() {
    local current_usage=$(get_memory_usage)
    local swap_active=$(swap_exists && echo "yes" || echo "no")
    
    log_message "INFO" "Memory usage: ${current_usage}% | Swap active: ${swap_active}"
    
    if [[ $current_usage -ge $MEMORY_THRESHOLD ]]; then
        # High memory usage - create swap if not exists
        if ! swap_exists; then
            log_message "WARN" "Memory usage (${current_usage}%) exceeds threshold (${MEMORY_THRESHOLD}%)"
            if create_swap; then
                log_message "SUCCESS" "Swap created due to high memory usage"
            else
                log_message "ERROR" "Failed to create swap"
            fi
        fi
    else
        # Normal memory usage - remove swap if exists
        if swap_exists; then
            log_message "INFO" "Memory usage (${current_usage}%) below threshold (${MEMORY_THRESHOLD}%)"
            if remove_swap; then
                log_message "SUCCESS" "Swap removed due to normal memory usage"
            else
                log_message "ERROR" "Failed to remove swap"
            fi
        fi
    fi
}

# Main monitoring loop
main_loop() {
    log_message "INFO" "Dynamic Swap Manager started"
    log_message "INFO" "Memory threshold: ${MEMORY_THRESHOLD}%, Swap size: ${SWAP_SIZE_GB}GB, Check interval: ${CHECK_INTERVAL}s"
    
    while true; do
        monitor_memory
        sleep $CHECK_INTERVAL
    done
}

# Single check mode (for cron jobs)
single_check() {
    log_message "INFO" "Running single memory check"
    monitor_memory
}

# Cleanup function
cleanup() {
    log_message "INFO" "Dynamic Swap Manager stopping"
    exit 0
}

# Trap signals for cleanup
trap cleanup SIGTERM SIGINT

# Display help
show_help() {
    echo "Dynamic Swap Manager"
    echo "===================="
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -d, --daemon     Run as daemon (continuous monitoring)"
    echo "  -c, --check      Single memory check"
    echo "  -s, --status     Show current status"
    echo "  -h, --help       Show this help"
    echo ""
    echo "Configuration:"
    echo "  Swap file: $SWAP_FILE"
    echo "  Swap size: ${SWAP_SIZE_GB}GB"
    echo "  Memory threshold: ${MEMORY_THRESHOLD}%"
    echo ""
    echo "Examples:"
    echo "  $0 --daemon      # Run as continuous daemon"
    echo "  $0 --check       # Run single check"
    echo "  $0 --status      # Show current status"
}

# Show status
show_status() {
    echo "=== Dynamic Swap Manager Status ==="
    echo "Memory threshold: ${MEMORY_THRESHOLD}%"
    echo "Swap file path: $SWAP_FILE"
    echo "Swap file size: ${SWAP_SIZE_GB}GB"
    echo "Check interval: ${CHECK_INTERVAL} seconds"
    echo ""
    
    local current_usage=$(get_memory_usage)
    echo "Current memory usage: ${current_usage}%"
    
    if swap_exists; then
        echo "Swap status: ACTIVE"
        swapon --show | grep "$SWAP_FILE"
    else
        echo "Swap status: INACTIVE"
    fi
    
    echo ""
    echo "Last 10 log entries:"
    tail -10 /var/log/dynamic-swap.log 2>/dev/null || echo "No log file found"
}

# Parse command line arguments
case "${1:-}" in
    -d|--daemon)
        check_root
        main_loop
        ;;
    -c|--check)
        check_root
        single_check
        ;;
    -s|--status)
        show_status
        ;;
    -h|--help|*)
        show_help
        ;;
esac
