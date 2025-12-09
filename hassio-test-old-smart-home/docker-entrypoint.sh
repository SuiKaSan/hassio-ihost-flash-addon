#!/usr/bin/env bashio

# 设置 bashio 日志级别为 info，确保所有日志都能显示
export __BASHIO_LOG_LEVEL=5

bashio::log.info "os info: "
OS=$(bashio::os)
bashio::log.info "$OS"
BOARD=$(echo "$OS" | jq -r '.board')
bashio::log.info "Current Board: $BOARD"

bashio::log.info "Node version: $(node --version)"
bashio::log.info "Npm version: $(npm --version)"
bashio::log.info "Current Add-on version is $(bashio::addon.version)"

# Check whether it is launched in an iHost environment
IN_IHOST=1
if [ "$BOARD" != "ihost" ]; then
    IN_IHOST=0
    bashio::log.info "We are not in iHost environment, current board: $BOARD"
fi

FLASHER_INFO=$(bashio::addons "sonoff_dongle_flasher_for_ihost")
bashio::log.info "Flasher Addon info: $FLASHER_INFO"


FLASHER_STATE=$(bashio::addon.state "sonoff_dongle_flasher_for_ihost")
bashio::log.info "Flasher Addon state: $FLASHER_STATE"

if bashio::config.true 'enable_conflict_detection'; then
    bashio::log.info "Conflict detection enabled"
else
    bashio::log.info "Conflict detection not enabled"
fi

bashio::log.info "Starting application..."

exec "$@"