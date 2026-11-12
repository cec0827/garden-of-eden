#!/bin/bash

# Configuration
BIN_DIR=$(dirname $(readlink -f $0))
INSTALL_DIR=$(realpath $BIN_DIR/..)

# Colors
GRN="\e[32m"
RED="\e[31m"
GRY="\e[90m"
LGY="\e[37m"
RST="\e[0m"

# Logging functions
function log_error {
    echo -e "[${RED}ERROR${RST}]: $*" >&2
}

function log_pass {
    echo -e "[${GRN}PASS${RST}]: $*"
}

function log_info {
    echo -e "[${GRY}INFO${RST}]: ${LGY}$*${RST}" >&2
}

# Setup and start the REST API + web UI service (served by waitress on :5000).
function setup_api_service {
    local service_file="$INSTALL_DIR/services/etc/systemd/system/garden-api.service"
    mkdir -p "$(dirname "$service_file")"

    cat > $service_file <<EOF

[Unit]
Description=Garden of Eden REST API + Web UI
After=network.target pigpiod.service
Wants=pigpiod.service

[Service]
User=$USER
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/venv/bin/waitress-serve --listen=0.0.0.0:5000 --threads=100 run:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    sudo cp $service_file /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable garden-api.service
    sudo systemctl start garden-api.service
    log_info "Web UI/API service started on http://$(hostname).local:5000"
}

sudo systemctl stop garden-api.service
sudo systemctl disable garden-api.service

setup_api_service
