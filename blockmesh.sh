
#!/bin/bash

# Цвета текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

logo=$(cat << 'EOF'
\033[32m
███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ 
████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗
██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║
╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
\033[0m
Подписаться на канал may.crypto{🦅}, чтобы быть в курсе самых актуальных нод - https://t.me/maycrypto
EOF
)

echo -e "$logo"

# Проверка наличия curl и установка, если не установлен
if ! command -v curl &> /dev/null; then
    sudo apt update
    sudo apt install curl -y
fi
sleep 1

# Проверка наличия bc и установка, если не установлен
echo -e "${GREEN}Проверяем версию вашей OS...${NC}"
if ! command -v bc &> /dev/null; then
    sudo apt update
    sudo apt install bc -y
fi
sleep 1

# Проверка версии Ubuntu
UBUNTU_VERSION=$(lsb_release -rs)
REQUIRED_VERSION=22.04

if (( $(echo "$UBUNTU_VERSION < $REQUIRED_VERSION" | bc -l) )); then
    echo -e "${RED}Для этой ноды нужна минимальная версия Ubuntu 22.04${NC}"
    exit 1
fi

# Меню
echo -e "${GREEN}Выберите действие:${NC}"
echo -e "${CYAN}1) Установка ноды${NC}"
echo -e "${CYAN}2) Проверка логов (выход из логов CTRL+C)${NC}"
echo -e "${CYAN}3) Обновить ноду до версии 0.0.331${NC}"
echo -e "${CYAN}4) Удаление ноды${NC}"

echo -e "${GREEN}Введите номер:${NC} "
read choice

case $choice in
    1)
        echo -e "${GREEN}Устанавливаем ноду BlockMesh...${NC}"

        # Проверка наличия tar и установка, если не установлен
        if ! command -v tar &> /dev/null; then
            sudo apt install tar -y
        fi
        sleep 1
        
        # Скачиваем бинарник BlockMesh
        wget https://github.com/block-mesh/block-mesh-monorepo/releases/download/v0.0.331/blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz

        # Распаковываем архив
        tar -xzvf blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz
        sleep 1

        # Удаляем архив
        rm blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz

        # Переходим в папку ноды
        cd target/release

        # Запрашиваем данные у пользователя
        echo -e "${BLUE}Email BlockMesh:${NC}"
        read USER_EMAIL

        echo -e "${BLUE}Пароль BlockMesh:${NC}"
        read USER_PASSWORD

        # Определяем имя текущего пользователя и его домашнюю директорию
        USERNAME=$(whoami)

        if [ "$USERNAME" == "root" ]; then
            HOME_DIR="/root"
        else
            HOME_DIR="/home/$USERNAME"
        fi

        # Создаем или обновляем файл сервиса с использованием определенного имени пользователя и домашней директории
        sudo bash -c "cat <<EOT > /etc/systemd/system/blockmesh.service
[Unit]
Description=BlockMesh CLI Service
After=network.target

[Service]
User=$USERNAME
ExecStart=$HOME_DIR/target/x86_64-unknown-linux-gnu/release/blockmesh-cli login --email $EMAIL --password $PASSWORD
WorkingDirectory=$HOME_DIR/target/x86_64-unknown-linux-gnu/release
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT"

        # Обновляем сервисы и включаем BlockMesh
        sudo systemctl daemon-reload
        sleep 1
        sudo systemctl enable blockmesh
        sudo systemctl start blockmesh

        # Заключительный вывод
        echo -e "${GREEN}Установка завершена и нода запущена! Следи за состоянием ноды в Dashboard: https://app.blockmesh.xyz/ui/dashboard${NC}"

        # Проверка логов
        sudo journalctl -u blockmesh -f
        ;;

    2)
        # Проверка логов
        sudo journalctl -u blockmesh -f
        ;;

    3)
        echo -e "${GREEN}Обновляем ноду BlockMesh...${NC}"

        # Останавливаем сервис
        sudo systemctl stop blockmesh
        sudo systemctl disable blockmesh
        sudo rm /etc/systemd/system/blockmesh.service
        sudo systemctl daemon-reload
        sleep 1

        # Удаляем старые файлы ноды
        rm -rf target
        sleep 1

        # Скачиваем новый бинарник BlockMesh
        wget https://github.com/block-mesh/block-mesh-monorepo/releases/download/v0.0.331/blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz

        # Распаковываем архив
        tar -xzvf blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz
        sleep 1

        # Удаляем архив
        rm blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz

        #Переходим в папку
        cd target/x86_64-unknown-linux-gnu/release/

        # Запрашиваем данные у пользователя для обновления переменных
        echo -e "${BLUE}Введите ваш email для BlockMesh:${NC} "
        read EMAIL
        echo -e "${BLUE}Введите ваш пароль для BlockMesh:${NC} "
        read PASSWORD

        # Определяем имя текущего пользователя и его домашнюю директорию
        USERNAME=$(whoami)
        HOME_DIR=$(eval echo ~$USERNAME)

        # Создаем или обновляем файл сервиса
        sudo bash -c "cat <<EOT > /etc/systemd/system/blockmesh.service
[Unit]
Description=BlockMesh CLI Service
After=network.target

[Service]
User=$USERNAME
ExecStart=$HOME_DIR/target/x86_64-unknown-linux-gnu/release/blockmesh-cli login --email $EMAIL --password $PASSWORD
WorkingDirectory=$HOME_DIR/target/x86_64-unknown-linux-gnu/release
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT"

        # Перезапускаем сервис
        sudo systemctl daemon-reload
        sleep 1
        sudo systemctl enable blockmesh
        sudo systemctl restart blockmesh

        # Заключительный вывод
        echo -e "${GREEN}Обновление успешно завершено, нода запущена! Следи за состоянием ноды в Dashboard: https://app.blockmesh.xyz/ui/dashboard${NC}"

        ;;

    4)
        echo -e "${RED}Удаление ноды BlockMesh...${NC}"

        # Остановка и отключение сервиса
        sudo systemctl stop blockmesh
        sudo systemctl disable blockmesh
        sudo rm /etc/systemd/system/blockmesh.service
        sudo systemctl daemon-reload
        sleep 1

        # Удаление папки target с файлами
        rm -rf target

        echo -e "${RED}Нода BlockMesh успешно удалена!${NC}"
        ;;
        
esac
