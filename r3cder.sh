#!/bin/bash

export IFS='
'

# - COLORS - #
green="\e[01;32m"; red="\e[01;31m"
blue="\e[01;34m"; yellow="\e[01;33m"
cyan="\e[01;36m"; purple="\e[01;35m"
end="\e[00m"

# - CUSTOM VARIABLES - #
NBOX="${blue}[${cyan}*${blue}]${end}"

# - Functions - #
function CTRL_C(){
  echo -e "\n${red}>>> ${blue}Process Canceled${red} <<<${end}\n"
  tput cnorm
  exit 0
}
function ERROR(){
  message="${1}"
  echo -e "${red}Error${blue}: ${end}${1}"
  tput cnorm
  exit 1
}
trap CTRL_C INT
trap ERROR SIGTERM


function RECDER(){
  local pathDirectory=${1}

  if [[ ${pathDirectory: -1} == '/' ]]; then
    local pathDirectory="${pathDirectory%?}"
  fi

  local listFiles=$(ls -A ${pathDirectory} 2>/dev/null)
  
  for file in ${listFiles}; do
    if [[ -f ${pathDirectory}/${file} ]]; then
      sleep 0.8
      echo -e "${purple}-> ${red}Corroding ${blue}> ${purple}${file}${end}\c"
      `shred -fzun2 ${pathDirectory}/${file} 2>/dev/null`
      if  [[ $? -eq 0 ]]; then
        echo -e "${green} done ${end}"
      else
        echo -e "${red} failed ${end}"
        ERROR "${red}Error to Corroding ${end}"
      fi
    else
      sleep 0.2
      echo -e "${blue}>>> ${cyan}${pathDirectory}/${file}${end}"
      newPathDirectory="${pathDirectory}/${file}"
      RECDER "${newPathDirectory}"
    fi
  done
}


function HELP_MENU(){
  clear
  echo -e "${blue}Parameters:${end}"
  echo -e "${purple} -d \tSpecify a Directory.${end}"
  echo -e "${purple} -h \tShow the Help Menu.${end}"
  echo -e "${purple} --help${end}"
  echo -e "${blue}use: ${red}${0} -d <path directory>${end}"
}

sleep 0.4
if [[ ${#} -eq 2 ]]; then
  declare -i count=0
  while getopts ":d:h:" args; do
    case $args in
      d) pathDirectory=$OPTARG; let count+=1;;
      h) HELP_MENU ;;
      *) HELP_MENU ;;
    esac
  done
  if [[ ${count} -ne 0 ]]; then
    clear; tput civis
    echo -e "${NBOX} ${blue}Checking Directory${yellow}.......${end}\c"
    sleep 1
    if [[ -d ${pathDirectory} ]]; then
      echo -e "${green} done ${end}"
      sleep 1
      countFiles=$(ls -A ${pathDirectory} 2>/dev/null | wc -l)
      echo -e "${NBOX} ${blue}Checking Files${yellow}.......${end}\c"
      sleep 1
      if [[ ${countFiles} -ne 0 ]]; then
        echo -e "${green} done ${end}"
        RECDER "${pathDirectory}"
      else
        echo -e "${red} failed ${end}"
        sleep 0.8
        ERROR "${blue} No files in ${red}${pathDirectory} ${blue}directory${end}"
      fi
    else
      echo -e "${red} failed ${end}"
      sleep 0.8
      ERROR "${blue}Directory ${red}${pathDirectory} ${blue}Not Exists${end}" 
    fi
  fi
  tput cnorm
else
  HELP_MENU
fi
