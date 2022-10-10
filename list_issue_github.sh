#!/bin/bash

echo -e " _____  _   _ ___________         _____  _____    ___ "
echo -e "|  __ \| | | |_   _|  _  \       |  _  |/ __  \  /   |"
echo -e "| |  \/| |_| | | | | | | | __   _| |/' |\`' / /' / /| |"
echo -e "| | __ |  _  | | | | | | | \ \ / /  /| |  / /  / /_| |"
echo -e "| |_\ \| | | |_| |_| |/ /   \ V /\ |_/ /./ /___\___  |"
echo -e " \____/\_| |_/\___/|___/     \_/  \___(_)_____(_)  |_/"
echo -e "                                                      "
echo -e "                                                      "

echo "GitHub issues downloader v0.2.4"

read -p "to run the script you need to have installed brew on your system. Press enter to continue"

if which -s brew; then
  echo "Brew installation found"
else
  echo "ERROR: brew installation not found"
  exit 3
fi

echo "*****START*****"
brew update
echo "checking if gh, jq and dasel are installed on your system"
# Install gh if it is missing
brew list gh || brew install gh
# Install dasel if it is missing
brew list jq || brew install jq
# Install dasel if it is missing
brew list dasel || brew install dasel
echo "checking if you are logged in gh"
# Log in if you are not
gh auth status || gh auth login

if [ $# -eq 0 ]; then
  #The "KEYBOARD" section allow to execute the script typing the parameters
  echo "enter the number of the last n items you want"
  read -r nitem
  if [[ -z "$nitem" ]]; then
    echo "ERROR: number of item is empty"
    exit 1
  fi

  if [ $nitem -le 0 ]; then
    echo "ERROR: number of item can not be 0 or less"
    exit 1
  fi

  if ! [[ $nitem =~ ^[0-9]+$ ]]; then
    echo "ERROR: Not a number"
    exit 1
  fi

  echo "Limit at $nitem issues"
  nitem="--limit ${nitem}"

  echo "enter the filter by the state you prefer: {open|closed|all}"
  read -r stateitem
  if [[ -z "$stateitem" ]]; then
    echo "ERROR: the state is empty"
    exit 1
  fi

  if [ $stateitem == "open" -o $stateitem == "closed" -o $stateitem == "all" ]; then
    echo "Selected $stateitem"
    stateitem="--state ${stateitem}"
  else
    echo "ERROR: illegal state entered"
    exit 1
  fi

  echo "enter the absolute path of the GitHub repo"
  read -r repopath
  if [[ -z "$repopath" ]]; then
    echo "ERROR: the path is empty"
    exit 1
  fi
  if [[ ! -d "$repopath" ]]; then
    echo "ERROR: the path does not exist or is not a directory"
    exit 2
  fi
  echo "Selected $repopath"
  cd ${repopath}
  if gh repo view; then
    echo "GitHub repo found"
  else
    echo "ERROR: the path does not contain a GitHub repository"
    exit 2
  fi
else
  if [ $# -ne 3 ]; then
    echo "ERROR: illegal quantity of arguments"
    exit 1
  fi
  #The "PASSENGER" section allow to pass the parameters using the positional method

  # --limit <int> number of the lastest issues to fetch
  if [ $1 -le 0 ]; then
    echo "ERROR: number of item can not be 0 or less"
    exit 1
  fi

  if ! [[ $1 =~ ^[0-9]+$ ]]; then
    echo "ERROR: Not a number"
    exit 1
  fi

  echo "Limit at $1 issues"
  nitem="--limit $1"

  # --state <string> Filter by state: {open|closed|all}
  if [ $2 == "open" -o $2 == "closed" -o $2 == "all" ]; then
    stateitem="--state $2"
    echo "State: $2"
  else
    echo "ERROR: illegal state entered"
    exit 1
  fi

  if [ ! -d $3 ]; then
    echo "ERROR: the path does not exist or is not a directory"
    exit 2
  fi
  echo "Selected $3"
  cd $3
  if gh repo view; then
    echo "GitHub repo found"
  else
    echo "ERROR: the path does not contain a GitHub repository"
    exit 2
  fi
fi

gh issue list ${nitem} ${stateitem} --json closedAt,createdAt,milestone,labels,number,projectCards,state,title,updatedAt,url | jq '[.[] | {number, state, title, closedAt, createdAt, updatedAt, url, labels: [.labels[].name], milestone: .milestone.title, project: .projectCards[].project.name, column: .projectCards[].column.name }]' | dasel -r json -w csv >"$(printf '%q\n' "${PWD##*/}").csv"
# Print the result
cat "$(printf '%q\n' "${PWD##*/}").csv"

echo "You can find the csv file named $(printf '%q\n' "${PWD##*/}").csv in the repo's root:"
pwd
echo "*****END*****"

exit 0
