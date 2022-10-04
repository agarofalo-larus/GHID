#!/bin/bash
echo "GitHub issues downloader v0.1"
read -p "to run the script you need to have installed brew on your system. Press enter to continue"
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

# --state <string> Filter by state: {open|closed|all}
# --limit <int> number of the lastest issues to fetch

gh issue list --limit 1000 --state all --json closedAt,createdAt,labels,number,projectCards,state,title,updatedAt,url | jq '[.[] | {number, state, title, closedAt, createdAt, updatedAt, url, labels: [.labels[].name], project: .projectCards[].project.name, column: .projectCards[].column.name }]' | dasel -r json -w csv >issuetest.csv

# Print the result
cat issuetest.csv

exit 0