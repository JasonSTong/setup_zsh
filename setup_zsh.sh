#!/bin/bash

# 检测系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
fi

# 定义安装命令
install_command() {
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt update
        sudo apt install -y "$1"
    elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ] || [ "$OS" = "fedora" ]; then
        sudo yum -y install "$1"
    else
        echo "不支持的操作系统"
        exit 1
    fi
}

# 检查zsh是否已经安装
if which zsh >/dev/null 2>&1; then
    echo "zsh 已经安装，跳过安装步骤..."
else
    echo "开始安装zsh..."
    install_command zsh
fi

# 检查默认shell是否为zsh
CURRENT_SHELL=$(getent passwd $USER | cut -d: -f7)
if [ "$CURRENT_SHELL" != "/bin/zsh" ]; then
    echo "设置默认shell为zsh..."
    sudo chsh -s /bin/zsh
    sudo chsh -s /bin/zsh $USER
else
    echo "默认shell已经是zsh，跳过设置步骤..."
fi

# 检查git是否已经安装
if which git >/dev/null 2>&1; then
    echo "git 已经安装，跳过安装步骤..."
else
    echo "开始安装git..."
    install_command git
fi

# 检查oh-my-zsh是否已经安装
if [ ! -d "$HOME/.oh-my-zsh" ]
then
    echo "开始安装oh-my-zsh..."
    sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"
else
    echo "oh-my-zsh 已经安装，跳过安装步骤..."
fi

# 安装插件并更新.zshrc
PLUGINS="zsh-syntax-highlighting zsh-autosuggestions"  # 使用空格分隔的字符串
for PLUGIN_NAME in $PLUGINS
do
    PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$PLUGIN_NAME"
    
    # 检查插件是否已经安装
    if [ ! -d "$PLUGIN_DIR" ]
    then
        echo "开始安装插件 $PLUGIN_NAME..."
        git clone --depth=1 https://github.com/zsh-users/$PLUGIN_NAME.git $PLUGIN_DIR
    else
        echo "插件 $PLUGIN_NAME 已经安装，跳过安装步骤..."
    fi

    # 检查插件是否已经在.zshrc中
    if ! grep -q "$PLUGIN_NAME" ~/.zshrc
    then
        echo "开始添加插件 $PLUGIN_NAME 到 ~/.zshrc..."
        sed -i 's/^plugins=(/&'"$PLUGIN_NAME "'/' ~/.zshrc
    else
        echo "插件 $PLUGIN_NAME 已经在 ~/.zshrc 中，跳过添加步骤..."
    fi
done

echo "开始使.zshrc生效..."
# 替换 source 命令
if [ -f ~/.zshrc ]; then
    echo "配置已更新，请运行以下命令使配置生效："
    echo "exec zsh"
    # 或者直接执行新的 zsh 会话
    exec zsh
fi

echo "所有操作完成!"
