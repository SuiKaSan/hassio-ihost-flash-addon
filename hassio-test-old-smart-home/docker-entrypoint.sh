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

# 根据“短 slug”（config.json 里的那个）查找完整 slug
find_addon_full_slug() {
    local short_slug=$1

    # 取出所有已安装 add-on 的完整 slug 列表
    local installed
    installed="$(bashio::addons.installed)" || return 1

    # 从中挑出以 "_短slug" 结尾的那一个
    # 例如：81bc2df9_nodered 以 "_nodered" 结尾
    local full_slug
    full_slug="$(grep "_${short_slug}$" <<< "${installed}" | head -n 1)"

    if bashio::var.is_empty "${full_slug}"; then
        return 1
    fi

    echo "${full_slug}"
}

# 示例：查某个 add-on 的 state
short="sonoff_dongle_flasher_for_ihost_2"
FULL_SLUG="$(find_addon_full_slug "${short}")" || {
    bashio::log.warning "Addon with short slug '${short}' not found"
}

if ! bashio::var.is_empty "${FULL_SLUG}"; then
    STATE="$(bashio::addon.state "${FULL_SLUG}")"
    bashio::log.info "Addon ${FULL_SLUG} state: ${STATE}"
fi

if bashio::config.true 'enable_conflict_detection'; then
    bashio::log.info "Conflict detection enabled"
else
    bashio::log.info "Conflict detection not enabled"
fi

bashio::log.info "Starting application..."

exec "$@"