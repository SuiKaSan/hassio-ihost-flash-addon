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

bashio::log.info "This is a new version of add-on 1.4.6 with conflict detection feature."

find_addon_full_slug() {
    local short_slug=$1
    local installed full_slug line

    bashio::log.info "Finding full slug for short slug: ${short_slug}"

    # 获取列表
    installed="$(bashio::addons)" || return 1
    bashio::log.info "Installed addons raw: $(printf '%s' "$installed")"

    # 按行扫描，不受控制字符干扰
    while IFS= read -r line; do
        # 输出每一行进行调试
        bashio::log.info "Checking addon entry: $line"

        if [[ "$line" == *"_${short_slug}" ]]; then
            full_slug="$line"
            break
        fi
    done <<< "$installed"

    if bashio::var.is_empty "${full_slug}"; then
        bashio::log.warning "No full slug found for ${short_slug}"
        return 1
    fi

    bashio::log.info "Found match: ${full_slug}"
    echo "$full_slug"
}

# ============================================================
# 冲突检测逻辑（根据你的需求）
# 条件：
#   1. enable_conflict_detection = true
#   2. 目标 add-on已启动
#   → 阻止本 add-on 启动
# ============================================================
if bashio::config.true 'enable_conflict_detection'; then
    bashio::log.info "Conflict detection enabled"

    TARGET_SHORT_SLUG="sonoff_dongle_flasher_for_ihost_2"

    FULL_SLUG="$(find_addon_full_slug "${TARGET_SHORT_SLUG}")" || {
        bashio::log.warning "Target addon not found, skip conflict detection"
        FULL_SLUG=""
    }

    if ! bashio::var.is_empty "${FULL_SLUG}"; then
        STATE="$(bashio::addon.state "${FULL_SLUG}" 2>/dev/null || echo "unknown")"
        bashio::log.info "Addon ${FULL_SLUG} state: ${STATE}"

        if [ "${STATE}" = "started" ]; then
            bashio::log.fatal "Conflict detected: ${FULL_SLUG} is running. Aborting startup."
            exit 1
        fi
    fi
else
    bashio::log.info "Conflict detection not enabled"
fi

bashio::log.info "Starting application..."

exec "$@"