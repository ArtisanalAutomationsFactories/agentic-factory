# Version 1.3
#!/bin/bash

# Define accurate absolute infrastructure paths
WP_DIR="$HOME/agentic-factory/wp-multisite"
AP_DIR="$HOME/activepieces"
AT_DIR="$HOME/agentic-factory/atrium"

case "$1" in
    start)
        echo "=== Launching Artisanal Automations Core Environment ==="
        echo "Starting Ollama Engine..."
        sudo systemctl start ollama 2>/dev/null || ollama serve > /dev/null 2>&1 &
        echo "Igniting WordPress Multi-Tenant Staging Stack..."
        cd "$WP_DIR" && docker compose up -d
        echo "Igniting Client Portal (Atrium)..."
        cd "$AT_DIR" && docker compose up -d || echo "Atrium compose failed."
        echo "Igniting ActivePieces Orchestration Engine..."
        cd "$AP_DIR" && docker compose up -d
        echo "SUCCESS: Dev Environment is Live."
        ;;
    stop)
        echo "=== Halting Artisanal Automations Core Environment ==="
        echo "Stopping Container Architectures..."
        cd "$WP_DIR" && docker compose down
        cd "$AT_DIR" && docker compose down 2>/dev/null
        cd "$AP_DIR" && docker compose down
        echo "Stopping Ollama Engine..."
        sudo systemctl stop ollama 2>/dev/null
        sudo pkill ollama 2>/dev/null
        echo "SUCCESS: Environment Securely Hibernated."
        ;;
    status)
        echo "=== Core Systems Health Matrix ==="
        echo -n "Ollama Local AI: "
        pgrep ollama > /dev/null && echo "ONLINE" || echo "OFFLINE"
        echo "Active Containers:"
        docker ps --format "table {{.Names}}\t{{.Status}}"
        ;;
    *)
        echo "Usage: factory {start|stop|status}"
        exit 1
        ;;
esac