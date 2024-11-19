#!/bin/bash

tput reset
tput civis

# Put your logo here if nessesary

show_orange() {
    echo -e "\e[33m$1\e[0m"
}

show_blue() {
    echo -e "\e[34m$1\e[0m"
}

show_green() {
    echo -e "\e[32m$1\e[0m"
}

show_red() {
    echo -e "\e[31m$1\e[0m"
}

exit_script() {
    show_red "Скрипт остановлен (Script stopped)"
        echo ""
        exit 0
}

incorrect_option () {
    echo ""
    show_red "Неверная опция. Пожалуйста, выберите из тех, что есть."
    echo ""
    show_red "Invalid option. Please choose from the available options."
    echo ""
}

process_notification() {
    local message="$1"
    show_orange "$message"
    sleep 1
}

run_commands() {
    local commands="$*"

    if eval "$commands"; then
        sleep 1
        echo ""
        show_green "Успешно (Success)"
        echo ""
    else
        sleep 1
        echo ""
        show_red "Ошибка (Fail)"
        echo ""
    fi
}

print_logo () {
    echo
    show_orange "   ______  __    __       ___       __  .__   __. " && sleep 0.2
    show_orange "  /      ||  |  |  |     /   \     |  | |  \ |  | " && sleep 0.2
    show_orange " |  ,----'|  |__|  |    /  ^  \    |  | |   \|  | " && sleep 0.2
    show_orange " |  |     |   __   |   /  /_\  \   |  | |  .    | " && sleep 0.2
    show_orange " |   ----.|  |  |  |  /  _____  \  |  | |  |\   | " && sleep 0.2
    show_orange "  \______||__|  |__| /__/     \__\ |__| |__| \__| " && sleep 0.2
    show_orange " .______        ___           _______. _______    " && sleep 0.2
    show_orange " |   _  \      /   \         /       ||   ____|   " && sleep 0.2
    show_orange " |  |_)  |    /  ^  \       |   (---- |  |__      " && sleep 0.2
    show_orange " |   _  <    /  /_\  \       \   \    |   __|     " && sleep 0.2
    show_orange " |  |_)  |  /  _____  \  .----)   |   |  |____    " && sleep 0.2
    show_orange " |______/  /__/     \__\ |_______/    |_______|   " && sleep 0.2
    echo
    sleep 1
}

install_or_update_docker() {
    process_notification "Ищем Docker (Looking for Docker)..."
    if which docker > /dev/null 2>&1; then
        show_green "Docker уже установлен (Docker is already installed)"
        echo
        # Try to update Docker
        process_notification "Обновляем Docker до последней версии (Updating Docker to the latest version)..."

        if sudo apt install apt-transport-https ca-certificates curl software-properties-common -y &&
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" &&
            sudo apt-get update &&
            sudo apt-get install -y docker-compose-plugin &&
            sudo apt-get install --only-upgrade docker-ce docker-ce-cli containerd.io docker-compose-plugin -y; then
            sleep 1
            echo -e "Обновление Docker (Docker update): \e[32mУспешно (Success)\e[0m"
            echo ""
        else
            echo -e "Обновление Docker (Docker update): \e[31мОшибка (Error)\e[0m"
            echo ""
        fi
    else
        # Install docker
        show_red "Docker не установлен (Docker not installed)"
        echo
        process_notification "\e[33mУстанавливаем Docker (Installing Docker)...\e[0m"

        if sudo apt install apt-transport-https ca-certificates curl software-properties-common -y &&
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" &&
        sudo apt-get update &&
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y; then
            sleep 1
            echo -e "Установка Docker (Docker installation): \e[32mУспешно (Success)\e[0m"
            echo
        else
            echo -e "Установка Docker (Docker installation): \e[31mОшибка (Error)\e[0m"
            echo
        fi
    fi
}

install_or_update_go() {
    cd $HOME

    ver="1.22.0"
    go_tarball="go$ver.linux-amd64.tar.gz"

    if command -v go &>/dev/null; then
        current_version=$(go version | awk '{print $3}' | cut -c 3-)
        show_green "Найден (Found) Go: $current_version"

        # Сравниваем версии
        if [ "$(printf '%s\n' "$ver" "$current_version" | sort -V | head -n 1)" = "$ver" ] && [ "$ver" != "$current_version" ]; then
            show_blue "Обновляем (Updating) Go..."
        else
            show_green "Go установлен и обновлен (Installed and Updated) $current_version"
            return
        fi
    else
        show_orange "Устанавливаем (Installing) Go..."
    fi

    wget "https://golang.org/dl/$go_tarball"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$go_tarball"
    rm "$go_tarball"

    if ! grep -q "/usr/local/go/bin" ~/.bash_profile; then
        echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
    fi

    source ~/.bash_profile

    show_green "VERSION GO:"
    go version
}

while true; do
    print_logo
    show_green "------ MAIN MENU ------ "
    echo "1. Подготовка (Preparation)"
    echo "2. Установка (Installation)"
    echo "3. Создать/импортировать (Create/Import) Wallet and BLS"
    echo "4. Настроить (Tunning)"
    echo "5. Запуск/Остановка (Start/Stop)"
    echo "6. Обновить (Update)"
    echo "7. Логи (Logs)"
    echo "8. Мониторинг (Monitor)"
    echo "9. Выход (Exit)"
    echo
    read -p "Выберите опцию (Select option): " option

    case $option in
        1)
            # PREPARATION
            process_notification "Начинаем подготовку (Starting preparation)..."
            run_commands "cd $HOME && sudo apt update && sudo apt upgrade -y"

            process_notification "Docker"
            install_or_update_docker

            process_notification "Go"
            install_or_update_go

            echo
            show_green "--- ПОГОТОВКА ЗАЕРШЕНА. PREPARATION COMPLETED ---"
            echo
            ;;
        2)
            #INSTALLATION
            process_notification "Устанавливаем (Installing) Eigenlayer CLI"
            run_commands "curl -sSfL https://raw.githubusercontent.com/layr-labs/eigenlayer-cli/master/scripts/install.sh | sh -s"

            export PATH=$PATH:/root/bin

            process_notification "Проверяем (Checking)..."
            run_commands "eigenlayer --version"

            process_notification "Устанавливаем (Installing) Chainbase..."
            run_commands "git clone https://github.com/chainbase-labs/chainbase-avs-setup && cd $HOME/chainbase-avs-setup/holesky"

            echo 'export PATH=$PATH:/root/bin' >> ~/.bashrc
            source ~/.bashrc

            echo
            show_green "--- УСТАНОВЛЕНА. INSTALLED ---"
            echo
            ;;
        3)
            # WALLETS
            echo
            show_green "--- WALLET MENU ---"
            while true; do
                echo "1. Создать ECDSA (Create)"
                echo "2. Создать BLS (Create)"
                echo "3. Восстановить ECDSA (Import)"
                echo "4. Восстановить BLS (Import)"
                echo "5. Показать ключи (Show keys)"
                echo "6. Выход (Exit)"
                echo ""

                read -p "Введите номер опции (Enter option number): " option
                case $option in
                    1)
                        export PATH=$PATH:/root/bin
                        process_notification "Введите данные (ENTER DATA)..."
                        read -p "Введите (Enter) Wallet key name: " WALLET_KEY_NAME
                        process_notification "Создаем (Creating) wallet ecdsa key..."
                        run_commands "cd $HOME/chainbase-avs-setup/holesky && eigenlayer operator keys create --key-type ecdsa $WALLET_KEY_NAME"
                        ;;
                    2)
                        export PATH=$PATH:/root/bin
                        process_notification "Введите данные (ENTER DATA)..."
                        read -p "Введите (Enter) BLS key name: " BLS_KEY_NAME
                        process_notification "Создаем (Creating) BLS key..."
                        run_commands "cd $HOME/chainbase-avs-setup/holesky && eigenlayer operator keys create --key-type bls $BLS_KEY_NAME"
                        ;;
                    3)
                        export PATH=$PATH:/root/bin
                        process_notification "Введите данные (ENTER DATA)..."
                        read -p "Введите (Enter) Wallet key name: " WALLET_KEY_NAME
                        read -p "Введите (Enter) Wallet private key: " WALLET_PRIVATE_KEY
                        process_notification "Ипортируем (Importing) wallet..."
                        run_commands "cd $HOME/chainbase-avs-setup/holesky && eigenlayer operator keys import --key-type ecdsa $WALLET_KEY_NAME $WALLET_PRIVATE_KEY"
                        ;;
                    4)
                        export PATH=$PATH:/root/bin
                        read -p "Введите (Enter) BLS key name: " BLS_KEY_NAME
                        read -p "Введите (Enter) BLS private key: " BLS_PRIVATE_KEY
                        process_notification "Ипортируем (Importing) BLS..."
                        run_commands "cd $HOME/chainbase-avs-setup/holesky && eigenlayer operator keys import --key-type bls $BLS_KEY_NAME $BLS_PRIVATE_KEY"
                        ;;
                    5)
                        export PATH=$PATH:/root/bin
                        process_notification "Ищем ключи (Looking for keys)..."
                        run_commands "cd $HOME/chainbase-avs-setup/holesky && eigenlayer operator keys list"
                        ;;
                    6)
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        4)
            # Create config file
            process_notification "Создаем (creating) config file..."
            run_commands "cd $HOME/chainbase-avs-setup/holesky && eigenlayer operator config create"

            # Create metadata.json
            read -p "Введите имя (Enter name): " NAME
            read -p "Введите веб-сайт (Enter website): " WEBSITE
            read -p "Введите описание (Enter description): " DESCRIPTION
            read -p "Введите RAW GITHUB URL логотипа (Enter logo GITHUB URL): " LOGO
            read -p "Введите Twitter (Enter twitter): " TWITTER

            FILE="$HOME/chainbase-avs-setup/holesky/metadata.json"
            cat > "$FILE" <<EOF
{
    "name": "$NAME",
    "website": "$WEBSITE",
    "description": "$DESCRIPTION",
    "logo": "$LOGO",
    "twitter": "$TWITTER"
}
EOF
            if [[ -f "$FILE" && -s "$FILE" ]]; then
                show_green "metadata.json создан (created)"
            else
                show_red "metadata.json не создан (not created)"
            fi

            # input logo url to operator.yaml
            FILE="/root/chainbase-avs-setup/holesky/operator.yaml"
            read -p "Введите RAW URL для logo (Enter new raw logo url): " LOGO_URL
            sed -i "s|metadata_url: .*|metadata_url: \"$LOGO_URL\"|" "$FILE"

                if grep -q "metadata_url: \"$LOGO_URL\"" "$FILE"; then
                    show_green "URL обновлён на: $LOGO_URL"
                else
                    show_red "URL не обновлён"
                fi

            process_notification "Регистрируем оператора (Register an operator)..."
            run_commands "cd $HOME/chainbase-avs-setup/holesky && eigenlayer operator register operator.yaml"

            process_notification "Проверяем статус 1 минуту (Checking status for 1 minute)..."
            sleep 60
            run_commands "cd $HOME/chainbase-avs-setup/holesky && eigenlayer operator status operator.yaml"

            process_notification "Меняем (Changing) ENV.... "
            read -p "Введите путь ECDSA (Enter ECDSA path): " ECDSA_PATH
            read -p "Введите пароль ECDSA (Enter ECDSA password): " ECDSA_PASSWORD
            read -p "Введите путь BLS (Enter BLS path)" BLS_PATH
            read -p "Введите пароль BLS (Enter BLS password): " BLS_PASSWORD

            read -p "Введите ETH aдрес (Enter ETH address): " ECDSA_ADDRESS
            read -p "Введите имя оператора (Enter Operator name): " OPERATOR_NAME

            OPERATOR_ASDRESS=$(hostname -I | awk '{print $1}')

            FILE="$HOME/chainbase-avs-setup/holesky/.env"
            cat > "$FILE" <<EOF
NODE_ECDSA_KEY_FILE_PATH=$ECDSA_PATH
NODE_BLS_KEY_FILE_PATH=$BLS_PATH
OPERATOR_ECDSA_KEY_PASSWORD=$ECDSA_PASSWORD
OPERATOR_BLS_KEY_PASSWORD=$BLS_PASSWORD

OPERATOR_ADDRESS=$ECDSA_ADDRESS
NODE_SOCKET=$OPERATOR_ASDRESS:8011

OPERATOR_NAME=$OPERATOR_NAME
EOF
            echo
            show_green "--- НАСТРОЕНА. TUNNED ---"
            echo
            ;;
        5)
            # START/STOP
            while true; do
                show_green "------ OPERATIONAL MENU ------ "
                echo "1. Зaпуск (Start)"
                echo "2. Остановка (Stop)"
                echo "3. Выход (Exit)"
                echo
                read -p "Выберите опцию (Select option): " option
                echo
                case $option in
                    1)
                        process_notification "Запускаем (Starting)..."
                        run_commands "cd $HOME/chainbase-avs-setup/holesky && chmod +x ./chainbase-avs.sh && ./chainbase-avs.sh register && ./chainbase-avs.sh run"
                        ;;
                    2)
                        process_notification "Запускаем (Starting)..."
                        run_commands "cd $HOME/chainbase-avs-setup/holesky && chmod +x ./chainbase-avs.sh && ./chainbase-avs.sh stop"
                        ;;
                    3)
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        6)
            # UPDATE
            while true; do
                show_green "------ OPERATIONAL MENU ------ "
                echo "1. Обновить (Update) Chainbase"
                echo "2. Обновить (Update) Eigenlayer"
                echo "3. Выход (Exit)"
                echo
                read -p "Выберите опцию (Select option): " option
                echo
                case $option in
                    1)
                        process_notification "Обновляем (Updating) Chaibase..."
                        run_commands "cd $HOME/chainbase-avs-setup/holesky && ./chainbase-avs.sh stop && ./chainbase-avs.sh update && ./chainbase-avs.sh run"
                        ;;
                    2)
                        process_notification "Обновляем (Updating) Eigenlayer..."

                        process_notification "Останавливаем (Stopping) Chainbase..."
                        run_commands "cd $HOME/chainbase-avs-setup/holesky && ./chainbase-avs.sh stop"

                        process_notification "Скачиваем (Download) Eigenlayer..."
                        run_commands "curl -sSfL https://raw.githubusercontent.com/layr-labs/eigenlayer-cli/master/scripts/install.sh | sh -s"

                        VERSION=$(cd $HOME/bin && ./eigenlayer --version)
                        show_green "$VERSION"

                        process_notification "Запускаем (Starting) Chainbase..."
                        run_commands "cd $HOME/chainbase-avs-setup/holesky && ./chainbase-avs.sh run"
                        ;;
                    3)
                        break
                        ;;
                    *)
                        incorrect_option
                        ;;
                esac
            done
            ;;
        7)
            # LOGS
            process_notification "Логи (Logs)..."
            sleep 2
            run_commands "cd $HOME/chainbase-avs-setup/holesky && docker compose logs -f"
            ;;
        8)
            # MONITORING
            OPERATOR_ASDRESS=$(hostname -I | awk '{print $1}')
            show_green "Клик (Click) --- > http://$OPERATOR_ASDRESS:3010"
            ;;
        9)
            exit_script
            ;;
        *)
            incorrect_option
            ;;
    esac
done
