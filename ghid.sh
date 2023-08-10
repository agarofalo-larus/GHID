#!/bin/bash

SHORT=l:,n:,h,s:,p:
OPTS=$(getopt $SHORT $*)

help() {
  echo "
    Usage: list_issue_github.sh
    -l <label>              Label you want to filter by
    -h                      Show this help message and exit
    -n <number>             Number of the last n items to retrieve
    -s {open|closed|all}    State of the items to retrieve
    -p <absolute-path>      Absolute path to the github repo
    "
}

already_set() {
  # Through indirect expansion, we check if the variable named like the first argument ($1) is already assigned
  if ! [[ -z ${!1} ]]; then
    echo "$2 is already assigned"
    exit 1
  fi
}

echo -e " _____  _   _ ___________          __   _____  _____ "
echo -e "|  __ \| | | |_   _|  _  \        /  | |  _  ||  _  |"
echo -e "| |  \/| |_| | | | | | | | __   __\`| | | |/' || |/' |"
echo -e "| | __ |  _  | | | | | | | \ \ / / | | |  /| ||  /| |"
echo -e "| |_\ \| | | |_| |_| |/ /   \ V / _| |_\ |_/ /\ |_/ /"
echo -e " \____/\_| |_/\___/|___/     \_/  \___(_)___(_)\___/ "
echo -e "                                                     "

echo "GitHub issues downloader v1.0.0"

eval set -- "$OPTS"

while :; do
  case "$1" in
  -l)
    already_set "labelitem" "label"
    labelitem="$2"
    shift 2
    ;;
  -h)
    help
    exit 0
    ;;
  -n)
    already_set "nitem" "number of items"
    nitem="$2"
    shift 2
    ;;
  -s)
    already_set "stateitem" "status"
    stateitem="$2"
    shift 2
    ;;
  -p)
    already_set "repopath" "absolute path to repository"
    repopath="$2"
    shift 2
    ;;
  *)
    echo "ERROR: unexpected option"
    help
    exit 1
    ;;
  esac
done

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
# Install jq if it is missing
brew list jq || brew install jq
# Install dasel if it is missing
brew list dasel || brew install dasel
echo "checking if you are logged in gh"
# Log in if you are not
gh auth status || gh auth login

nitem=${nitem:-20}
stateitem=${stateitem:-all}

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

if [ $stateitem == "open" -o $stateitem == "closed" -o $stateitem == "all" ]; then
  echo "Selected $stateitem"
  stateitem="--state ${stateitem}"
else
  echo "ERROR: illegal state entered"
  exit 1
fi

if [[ -z "$repopath" ]]; then
  echo "ERROR: the path is empty"
  exit 3
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

if [[ ! -z "$labelitem" ]]; then
  echo "Selected $labelitem"
  labelitem="-l ${labelitem}"
else
  echo "The file will contain any kind of labels"
fi

if [[ $(gh issue list --json projectItems | jq '[.[] | {project: .projectItems[].title}]' | jq length) -ne 0 ]]; then
  # The repo is using the new GitHub project board
  gh auth status | grep project || gh auth refresh -s project
  gh issue list ${nitem} ${stateitem} ${labelitem} --json closedAt,createdAt,milestone,labels,number,projectItems,state,title,updatedAt,url | jq '[.[] | {number, state, title, closedAt, createdAt, updatedAt, url, labels: [.labels[].name], milestone: .milestone.title, project: .projectItems[].title}]' | dasel -r json -w csv >"$(printf '%q\n' "${PWD##*/}").csv"
else
  # The repo is using the old GitHub project board
  gh issue list ${nitem} ${stateitem} ${labelitem} --json closedAt,createdAt,milestone,labels,number,projectCards,state,title,updatedAt,url | jq '[.[] | {number, state, title, closedAt, createdAt, updatedAt, url, labels: [.labels[].name], milestone: .milestone.title, project: .projectCards[].project.name, column: .projectCards[].column.name }]' | dasel -r json -w csv >"$(printf '%q\n' "${PWD##*/}").csv"
fi
# Print the result
cat "$(printf '%q\n' "${PWD##*/}").csv"

echo "You can find the csv file named $(printf '%q\n' "${PWD##*/}").csv in the repo's root:"
pwd
echo "*****END*****"

exit 0
