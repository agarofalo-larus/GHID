#!/bin/bash
echo "GitHub issues downloader v0.2.1"
read -p "to run the script you need to have installed brew on your system. Press enter to continue"
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
  else

    if [ $nitem -le 0 ]; then
      echo "ERROR: number of item can not be 0 or less"
      exit 1
    else
      echo "Limit at $nitem issues"
      nitem="--limit ${nitem}"
    fi

  fi

  echo "enter the filter by the state you prefer: {open|closed|all}"
  read -r stateitem
  if [[ -z "$stateitem" ]]; then
    echo "ERROR: the state is empty"
    exit 1
  else
    if [ $2 == "open" ] || [ $2 == "closed" ] || [ $2 == "all" ]; then
      echo "Selected $stateitem"
      stateitem="--state ${stateitem}"
      echo $stateitem
    else
      echo "ERROR: illegal state entered"
      exit 1
    fi
  fi

  echo "enter the absolute path of the GitHub repo"
  read -r repopath
  if [[ -z "$repopath" ]]; then
    echo "ERROR: the path is empty"
    exit 1
  else
    if [[ ! -d "$repopath" ]]; then
      echo "ERROR: the path does not exist or is not a directory"
      exit 2
    else
      echo "Selected $repopath"
      cd ${repopath}
      echo $repopath
    fi
  fi
else
  if [ $# -ne 3 ]; then
    echo "ERROR: illegal quantity of arguments"
    exit 1
  fi
  #The "PASSENGER" section allow to pass the parameters using the positional method
  if [ $1 -le 0 ]; then
    echo "ERROR: number of item can not be 0 or less"
    exit 1
  else
    echo "Limit at $nitem issues"
    nitem="--limit $1"
  fi

  if [ $2 == "open" ] || [ $2 == "closed" ] || [ $2 == "all" ]; then
    stateitem="--state $2"
    echo "State: $2"
  else
    echo "ERROR: illegal state entered"
    exit 1
  fi

  if [ ! -d $3 ]; then
    echo "ERROR: the path does not exist or is not a directory"
    exit 2
  else
    echo "Selected $3"
    cd $3
    echo $3
  fi
fi

# --state <string> Filter by state: {open|closed|all}
# --limit <int> number of the lastest issues to fetch
#echo "gh issue list ${nitem} ${stateitem} --json closedAt,createdAt,labels,number,projectCards,state,title,updatedAt,url | jq '[.[] | {number, state, title, closedAt, createdAt, updatedAt, url, labels: [.labels[].name], project: .projectCards[].project.name, column: .projectCards[].column.name }]' | dasel -r json -w csv >issuetest.csv"
gh issue list ${nitem} ${stateitem} --json closedAt,createdAt,labels,number,projectCards,state,title,updatedAt,url >mario.json
cat mario.json | jq '[.[] | {number, state, title, closedAt, createdAt, updatedAt, url, labels: [.labels[].name] }]' >luigi.json
cat luigi.json | dasel -r json -w csv >issuetest.csv
# gh issue list ${nitem} ${stateitem} --json closedAt,createdAt,labels,number,projectCards,state,title,updatedAt,url | jq '[.[] | {number, state, title, closedAt, createdAt, updatedAt, url, labels: [.labels[].name], project: .projectCards[].project.name, column: .projectCards[].column.name }]' | dasel -r json -w csv >issuetest.csv
# Print the result
cat issuetest.csv

echo "*****END*****"

exit 0
