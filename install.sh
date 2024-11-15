#! /bin/bash

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
BLUE='\033[34m'

restore() {
    printf "%b\n" "\n${YELLOW}Reverting the changes...${RC}"
    if ! $CREATED; then
        printf "%b\n" "${YELLOW}Deleting ${RC}$CONFIG_DIR${YELLOW}...${RC}"
        rm -rf "$CONFIG_DIR"
    fi
    if ! $B_CREATED; then
        printf "%b\n" "${YELLOW}Restoring the old config...${RC}"
        rm -f "$CONFIG_DIR/config.json"
        mv "$CONFIG_DIR/$B_NAME" "$CONFIG_DIR/config.json"
    fi
    printf "%b\n" "${GREEN}Done.${RC}"
    exit 1
}

list_options() {
    i=0
    for o in "${OPTIONS[@]}"; do
        i=$((i + 1))
        if [ $i -lt 10 ]; then
            ident='  '
        else
            ident=' '
        fi
        printf "%b\n" "$ident${BLUE}$i${RC} | $o"
    done
}

read_input() {
    read -r input
    input=$((input - 1))
    if [ $input -ge ${#OPTIONS[@]} ] || [ $input -lt 0 ]; then
        printf "%b\n" "${RED}Invalid number:${RC} $((input + 1))"
        exit 1
    fi
}

printf "%b\n" "Chose your preferred flavor:"
OPTIONS=('latte' 'frappe' 'macchiato' 'mocha')
list_options
printf "%b" "Enter the number of your chosen flavor (${BLUE}1${RC}-${BLUE}4${RC}) | "
read_input
FLAVOR=${OPTIONS[$input]}

printf "%b\n" "\nChose your preferred accent:"
OPTIONS=('rosewater' 'flamingo' 'pink' 'mauve' 'red' 'maroon' 'peach' 'yellow' 'green' 'teal' 'sky' 'sapphire' 'blue' 'lavender')
list_options
printf "%b" "Enter the number of your chosen accent (${BLUE}1${RC}-${BLUE}4${RC}) | "
read_input
ACCENT=${OPTIONS[$input]}

printf "%b\n" "\nFlavor chosen: ${BLUE}$FLAVOR${RC}
Accent chosen: ${BLUE}$ACCENT${RC}\n"

if [ -z "$XDG_CONFIG_HOME" ]; then
    CONFIG_DIR="$HOME/.config/hyprlauncher"
else
    CONFIG_DIR="$XDG_CONFIG_HOME/hyprlauncher"
fi

if [ ! -d "$CONFIG_DIR" ]; then
    printf "%b\n" "${YELLOW}Creating ${RC}$CONFIG_DIR${YELLOW}...${RC}"
    mkdir -p "$CONFIG_DIR" || { printf "%b\n" "${RED}Failed to create ${RC}$CONFIG_DIR${RED}.${RC}"; restore; }
    CREATED=false
fi

if [ -f "$CONFIG_DIR/config.json" ]; then
    printf "%b\n" "${YELLOW}Backing up the old config...${RC}"
    B_NAME="config.json.$(date +%s).old"
    cp "$CONFIG_DIR/config.json" "$CONFIG_DIR/$B_NAME" || { printf "%b\n" "${RED}Failed to copy ${RC}$CONFIG_DIR/config.json${RED} to ${RC}$CONFIG_DIR/config.json.old${RED}.${RC}"; restore; }
    B_CREATED=false
    rm -f "$CONFIG_DIR/config.json" || { printf "%b\n" "${RED}Failed to delete ${RC}$CONFIG_DIR/config.json${RED}.${RC}"; restore; }
fi

printf "%b\n" "${YELLOW}Downloading ${RC}$FLAVOR-$ACCENT.json${YELLOW}...${RC}"
URL="https://raw.githubusercontent.com/adamperkowski/hyprlauncher/refs/heads/stable/configs/$FLAVOR-$ACCENT.json"
curl -fsL "$URL" -o "$CONFIG_DIR/config.json" || { printf "%b\n" "${RED}Failed to download ${RC}$URL${RED}."; restore; }
printf "%b\n" "${GREEN}Done.${RC}"
