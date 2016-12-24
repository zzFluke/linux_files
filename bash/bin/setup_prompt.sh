#! /usr/bin/env bash
# bash script that prints out custom prompt banner

# Grab host name
hostnam=$(echo -n $HOSTNAME | sed -e "s/[\.].*//")
# grab username
usernam=$(whoami)
# get current path
newPWD="${PWD}"
# compute prompt size
promptsize=$(echo -n "--(${usernam}@${hostnam})---(${PWD})--" | wc -c | tr -d " ")

# add extra dashes to fill terminal
let fillsize=$(tput cols)-${promptsize}
fill=""
while [ "$fillsize" -gt "0" ] 
do 
   fill="${fill}-"
   let fillsize=${fillsize}-1
done

# reduct path size
if [ "$fillsize" -lt "0" ]
then
    let cut=3-${fillsize}
    newPWD=$(echo -n $PWD | sed -e "s/\(^.\{$cut\}\)\(.*\)/\2/")
fi

# define colors
NO_COLOR="\033[0m"
LIGHT_BLUE="\033[1;34m"
YELLOW="\033[1;33m"

# echo out banner
echo -e "${YELLOW}-${LIGHT_BLUE}-(${YELLOW}${usernam}${LIGHT_BLUE}@${YELLOW}${hostnam}${LIGHT_BLUE})-\
${YELLOW}-${fill}${LIGHT_BLUE}-(${YELLOW}${newPWD}${LIGHT_BLUE})-${YELLOW}-${NO_COLOR}"
