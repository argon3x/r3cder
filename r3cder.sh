#!/bin/bash

### By: Argon3x
### Supported: Debian Based Systems and Termux
### Version: 2.0

export IFS='
'

# Colors
red='\033[01;31m'; green='\033[01;32m'; blue='\033[01;34m'
yellow='\033[01;33m'; purple='\033[01;35m'; grey='\033[01;30m' end='\033[00m'

box="${blue}[${green}+${blue}]${end}"

# function canceled and function error
signal_canceled(){
  echo -e "\n${blue}>>> ${red}Process Canceled ${blue}<<<${end}\n"
  tput cnorm
  exit 1
}

signal_error(){
  error=$1

  echo -e "\n${purple}Error${end}: ${grey}${error}\n"
  tput cnorm
  exit 1
}

# send the signal
trap signal_canceled SIGINT
trap signal_error SIGTERM


# show help menu
help_menu(){
  clear
  local name_script=${0##*/}
  
  echo -e "${yellow}Help Menu from ${name_script%.*}${end}"
  echo -e "${red}Warning${end}: ${blue}this script overwrite the files all of directory.${end}\n"
  echo -e "${purple} -d\t${blue}select a specific directory.${end}"
  echo -e "${purple} -h\t${blue}Show help menu.${end}\n"
  echo -e "${green}use: ${purple}./${name_script} -d <Directory>${end}"
}

# overwrite in zero, rename in zero and delete the files.
recder_files(){
  local path="$1"

  # check that the directory path does not end with a slash
  [[ ${path: -1} == '/' ]] && local path="${path%?}"

  # check if there are files inside the directory
  file_exist=$(ls -A -U -X -r ${path} 2>/dev/null)

  # iterate the directory
  for i in ${file_exist}; do
    # check file if exist 
    if [ -f "${path}/${i}" ]; then
      # total cores (threads)
      declare -i cores=$(nproc)

      # controls the flow of threads (default 10)
      while [[ $(jobs | wc -l) -ge ${cores} ]]; do
        sleep 1
      done

      echo -e "${grey}:> ${purple}overwriting file ${yellow}-> ${grey}$i${end}"
      
      # overwrite files to delete (default 2)
      `nice -n 5 shred -fzu -n 2 ${path}/${i} 2>/dev/null &`
      
    else
      # check that the directory contains files
      if [ $(ls -A "${path}/${i}" | wc -l) -ne 0 ]; then
        echo -e "${blue}(${green}overwrite in ${purple}${path}/${purple}${i}${blue})${end}"

        # call the same function
        recder_files "${path}/${i}"
      fi
    fi
  done; wait
}


# check the parameters
while getopts ':h:d:' args; do
  case $args in
    d) path_directory=$OPTARG; declare -i count=1 ;;
    \?) signal_error "${red}the ${purple}-$OPTARG ${red}parameter is invalid, use -h for more help.${end}" ;;
  esac
done

if [ $count -eq 1 ]; then
  # check directory if exist 
  clear && tput civis
  echo -e "${box} ${yellow}Checking Directory ${blue}(${yellow}${path_directory##*/}${blue})${yellow}...........${end}\c"; sleep 0.4

  if [ -d ${path_directory} ]; then
    echo -e "${green} done ${end}"
  else
    echo -e "${red} faild ${end}\n"
    signal_error "The ${path_directory} Not Exist"
  fi

  # Check that the directory is not empty
  files_count=$(ls -A ${path_directory} 2>/dev/null | wc -l)
  
  echo -e "${box} ${yellow}Checking files...........${end}\c"; sleep 0.4
  if [ $files_count -gt 0 ]; then
    echo -e "${green} done ${end}"

    # get directory weight
    data=($(du -sh ${path_directory} | awk -F ' ' '{print $1}') $(du -sh ${path_directory} | awk -F ' ' '{print $2}'))

    # count characters
    chars=$(echo ${data[@]} | wc -c)

    # function call to overwrite all files 
    recder_files $path_directory
    if [ $? -eq 0 ]; then
      echo
      for c in $(seq 0 ${chars}); do echo -e "${blue}-\c"; done; echo -e "-------------------------------${end}"
      echo -e "${green} ${data[0]} ${yellow}of space has been freed in the ${green}${data[1]}${end}"
      for c in $(seq 0 ${chars}); do echo -e "${blue}-\c"; done; echo -e "-------------------------------${end}"
      echo
    fi

  else
    echo -e "${red} faild ${end}"

    # count directory characters
    count_char=$(echo ${path_directory##*/} | wc -c)

    for c in $(seq 0 ${count_char}); do echo -e "${blue}-\c"; done; echo -e "------------------------------------${end}"
    echo -e "${yellow} The ${blue}(${purple}${path_directory##*/}${blue}) ${yellow}directory is empty, try again${end}"
    for c in $(seq 0 ${count_char}); do echo -e "${blue}-\c"; done; echo -e "------------------------------------${end}"

    tput cnorm; exit 0
  fi
  tput cnorm
else
  help_menu
fi
