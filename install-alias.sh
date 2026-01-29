#!/bin/bash
#=============================================================================
# 脚本名称: install-alias.sh
# 功能描述: 为 net-tcp-tune 脚本创建/卸载快捷别名
# 使用方法: 
#   安装: bash install-alias.sh [install]
#   卸载: bash install-alias.sh uninstall
#=============================================================================

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m' # No Color

# 检测操作模式（安装或卸载）
MODE="${1:-install}"
if [ "$MODE" != "install" ] && [ "$MODE" != "uninstall" ]; then
    echo -e "${RED}错误: 未知参数 '$MODE'${NC}"
    echo "使用方法:"
    echo "  安装: bash install-alias.sh [install]"
    echo "  卸载: bash install-alias.sh uninstall"
    exit 1
fi

# 检测当前使用的 shell
CURRENT_SHELL=$(basename "$SHELL")

# 根据不同的 shell 设置配置文件（检查多个可能的配置文件）
detect_rc_file() {
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        RC_FILE="$HOME/.zshrc"
    elif [ "$CURRENT_SHELL" = "bash" ]; then
        RC_FILE="$HOME/.bashrc"
        # 如果 .bashrc 不存在，使用 .bash_profile
        if [ ! -f "$RC_FILE" ]; then
            RC_FILE="$HOME/.bash_profile"
        fi
    else
        RC_FILE="$HOME/.bashrc"
    fi
    
    # 如果文件不存在，创建它
    if [ ! -f "$RC_FILE" ]; then
        touch "$RC_FILE"
    fi
}

detect_rc_file

# 卸载功能
uninstall_alias() {
    echo -e "${CYAN}=== 卸载 net-tcp-tune 快捷别名 ===${NC}"
    echo ""
    echo -e "检测到 Shell: ${GREEN}${CURRENT_SHELL}${NC}"
    echo -e "配置文件: ${GREEN}${RC_FILE}${NC}"
    echo ""
    
    # 检查别名是否已存在
    if ! grep -q "net-tcp-tune 快捷别名" "$RC_FILE" 2>/dev/null; then
        echo -e "${YELLOW}未找到已安装的别名，无需卸载${NC}"
        return
    fi
    
    # 删除别名配置块
    # 1. 尝试删除带注释块的旧格式
    sed -i '/^# ================/,/^alias dog=/d' "$RC_FILE" 2>/dev/null || true
    
    # 2. 删除新格式 (利用 sed 范围删除)
    sed -i '/net-tcp-tune 快捷别名/,/^alias bbr=/d' "$RC_FILE" 2>/dev/null || true
    
    # 3. 清理可能残留的 dog 别名
    if grep -q "alias dog=" "$RC_FILE"; then
        grep -v "alias dog=" "$RC_FILE" > "${RC_FILE}.tmp" && mv "${RC_FILE}.tmp" "$RC_FILE"
    fi
    
    echo -e "${GREEN}✅ 别名已从配置文件中移除${NC}"
    echo ""
    echo -e "${CYAN}请执行以下命令使更改生效：${NC}"
    echo -e "${YELLOW}source ${RC_FILE}${NC}"
    echo ""
}

# 安装功能
install_alias() {
    echo -e "${CYAN}=== 安装 net-tcp-tune 快捷别名 ===${NC}"
    echo ""
    echo -e "检测到 Shell: ${GREEN}${CURRENT_SHELL}${NC}"
    echo -e "配置文件: ${GREEN}${RC_FILE}${NC}"
    echo ""

    # 定义要写入的别名内容 (关键修改点：URL已替换为变量，请确保推送到您自己的仓库)
    # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    # 请修改下方的 YourName/YourRepo 为您实际的 GitHub 用户名和仓库名
    # ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
    
    local REPO_PATH="YourName/YourRepo" 
    
    ALIAS_CONTENT='
# net-tcp-tune 快捷别名
alias bbr="bash <(curl -fsSL \"https://raw.githubusercontent.com/'"${REPO_PATH}"'/main/net-tcp-tune.sh?\$(date +%s)\")"
alias dog="bash <(curl -fsSL \"https://raw.githubusercontent.com/'"${REPO_PATH}"'/main/Eric_port-traffic-dog.sh?\$(date +%s)\")"
'

    # 检查别名是否已存在
    if grep -q "net-tcp-tune 快捷别名" "$RC_FILE" 2>/dev/null; then
        echo -e "${YELLOW}配置已存在，正在更新...${NC}"
        
        # 备份文件
        cp "$RC_FILE" "${RC_FILE}.bak"
        
        # 清理旧配置
        if grep -q "^# ================" "$RC_FILE" 2>/dev/null; then
            sed -i '/^# ================/,/^alias dog=/d' "$RC_FILE" 2>/dev/null || sed -i '/^# ================/,/^alias bbr=/d' "$RC_FILE"
        else
             sed -i '/net-tcp-tune 快捷别名/,/^alias bbr=/d' "$RC_FILE"
        fi

        # 暴力清理残留的 alias dog=
        if grep -q "alias dog=" "$RC_FILE"; then
            grep -v "alias dog=" "$RC_FILE" > "${RC_FILE}.tmp" && mv "${RC_FILE}.tmp" "$RC_FILE"
        fi
        
        # 追加新配置
        echo "$ALIAS_CONTENT" >> "$RC_FILE"
        echo -e "${GREEN}✅ 别名已更新到 ${RC_FILE}${NC}"
        echo ""
    else
        # 添加别名到配置文件
        echo "$ALIAS_CONTENT" >> "$RC_FILE"
        echo -e "${GREEN}✅ 别名已添加到 ${RC_FILE}${NC}"
        echo ""
    fi
    
    echo -e "${CYAN}=== 快捷命令 ===${NC}"
    echo ""
    echo -e "  ${GREEN}bbr${NC}   - 一键运行系统优化脚本"
    echo -e "  ${GREEN}dog${NC}   - 一键运行端口流量狗"
    echo ""
    echo -e "${CYAN}=== 使用方法 ===${NC}"
    echo ""
    echo "1. 重新加载配置："
    echo -e "   ${YELLOW}source ${RC_FILE}${NC}"
    echo ""
    echo "2. 或者关闭终端重新打开"
    echo ""
    echo "3. 然后直接输入快捷命令："
    echo -e "   ${GREEN}bbr${NC} (系统优化)"
    echo -e "   ${GREEN}dog${NC} (端口监控)"
    echo ""
}

# 执行主逻辑
if [ "$MODE" = "uninstall" ]; then
    uninstall_alias
else
    install_alias
fi
