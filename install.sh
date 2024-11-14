#! /bin/sh

# TODO: 'restore' function in case something fails

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
BLUE='\033[34m'

printf "%b" "Chose your preferred flavor:
 ${BLUE}1${RC} | Latte
 ${BLUE}2${RC} | Frappe
 ${BLUE}3${RC} | Macchiato
 ${BLUE}4${RC} | Moccha
Enter the number of your chosen flavor (${BLUE}1${RC}-${BLUE}4${RC}) | "

read -r input
echo
case $input in
    1)
        FLAVOR='latte'
        ;;
    2)
        FLAVOR='frappe'
        ;;
    3)
        FLAVOR='macchiato'
        ;;
    4)
        FLAVOR='mocha'
        ;;
    *)
        printf "%b\n" "${RED}Invalid number:${RC} $input"
        exit 1
        ;;
esac

if [ -z $FLAVOR ]; then
    printf "%b\n" "${RED}Something went wrong. Try installing the theme manually.${RC}"
    exit 1
fi

printf "%b\n" "Flavor chosen: ${BLUE}$FLAVOR${BLUE}"

if [ -z "$XDG_CONFIG_HOME" ]; then
    CONFIG_DIR="$HOME/.config/hyprlauncher"
else
    CONFIG_DIR="$XDG_CONFIG_HOME/hyprlauncher"
fi

if [ ! -d "$CONFIG_DIR" ]; then
    printf "%b\n" "${YELLOW}Creating ${RC}$CONFIG_DIR${YELLOW}...${RC}"
    mkdir -p "$CONFIG_DIR"
fi

if [ -f "$CONFIG_DIR/config.json" ]; then
    printf "%b\n" "${YELLOW}Backing up the old config...${RC}"
    cp "$CONFIG_DIR/config.json" "$CONFIG_DIR/config.json.old" || { printf "%b\n" "${RED}Failed to copy ${RC}$CONFIG_DIR/config.json${RED} to ${RC}$CONFIG_DIR/config.json.old${RED}.${RC}"; exit 1; }
    rm -f "$CONFIG_DIR/config.json"
fi

printf "%b\n" "${YELLOW}Downloading ${RC}$FLAVOR.json${YELLOW}...${RC}"
URL="https://raw.githubusercontent.com/adamperkowski/hyprlauncher/refs/heads/stable/configs/$FLAVOR.json"
curl -fsL "$URL" -o "$CONFIG_DIR/config.json" || { printf "%b\n" "${RED}Failed to download ${RC}$URL${RED}."; exit 1; }
printf "%b\n" "${GREEN}Done.${RC}"
