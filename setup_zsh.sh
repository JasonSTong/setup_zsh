#!/bin/bash

# 检查zsh是否已经安装
if ! command -v zsh &> /dev/null
then
    echo "开始安装zsh..."
    sudo yum -y install zsh
else
    echo "zsh 已经安装，跳过安装步骤..."
fi

# 检查默认shell是否为zsh
if [ "$SHELL" != "/bin/zsh" ]
then
    echo "设置默认shell为zsh..."
    sudo chsh -s /bin/zsh
    sudo chsh -s /bin/zsh chenc
else
    echo "默认shell已经是zsh，跳过设置步骤..."
fi

# 检查git是否已经安装
if ! command -v git &> /dev/null
then
    echo "开始安装git..."
    sudo yum -y install git
else
    echo "git 已经安装，跳过安装步骤..."
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
PLUGINS=("zsh-syntax-highlighting" "zsh-autosuggestions")
for PLUGIN_NAME in "${PLUGINS[@]}"
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
source ~/.zshrc

echo "所有操作完成!"
