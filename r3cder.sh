#!/bin/bash

export IFS='
'

# colors
red="\e[01;31m"; green="\e[01;32m"
blue="\e[01;34m"; yellow="\e[01;33m"
purple="\e[01;35m"; end="\e[00m"


# signal canceled
signal_canceled(){
  echo -e "\n${red} process canceled ${end}\n"
  tput cnorm
  exit 1
}

# signal terminated
signal_terminated(){
  local error=$1

  echo -e "${red}[${end}ERROR${red}]${end} ${error}"
  tput cnorm
  exit 1
}

# send the signals
trap signal_canceled SIGINT
trap signal_terminated SIGTERM


# help menu
help_menu(){
cat << EOF
usage: ${0##*/} [-h] [-v] -d

description:
  the script corrupts the entire contents of a directory (overwriting)
  the files and rendering them unusable to end with the remove.

options:
  -d      selecct a directory with files to corrupts.
  -h      show help menu
  -v      script version
EOF
}

# 
overwriting_files(){
  local dirpath=$1
  
  for file in $(ls -A1 $dirpath); do
    new_path="${dirpath}/${file}"

    if [[ -f $new_path ]]; then
      echo -e "${blue}[${red}DESTROYING${blue}]${end} ${new_path}"
      shred -f -z -u -n 2 $new_path 2>/dev/null
    else
      overwriting_files $new_path
    fi
  done
}

start_recder(){
  tput civis # disable cursor
  local dpath=$1

  # check if the directory exists
  if ! [[ -d $dpath ]]; then
    signal_terminated "the directory does not exist"
  fi

  # remove last character if '/'
  [[ ${dpath: -1} == '/' ]] && dpath=${dpath%?}

  # get directory information
  directory_size=$(du -sh $dpath | awk -F ' ' '{print $1}')
  files_total=$(find $dpath -type f | wc -l)

  # check that files exist in the directory
  if [[ $files_total -eq 0 ]]; then
    echo
    signal_terminated "Nothing to corrput\n"
  fi

  echo -e "${purple}[*]${end} ${files_total} files were overwritten ($directory_size) are released\n"
  sleep 2
  
  overwriting_files $dpath

  tput cnorm # enable cursor
}


if [[ $# -ne 0 ]]; then
  # set arguments
  while getopts ":d:hv" args; do
    case $args in
      \?) signal_terminated "the -$OPTARG parameter not is valid"
        ;;
      :) signal_terminated "the -$OPTARG required an argument"
        ;;
      h) help_menu
        ;;
      v) echo -e "${green}${0##*/}${end} 3.0.1"
        ;;
      d) start_recder $OPTARG
        ;;
    esac
  done
else
  help_menu
fi
