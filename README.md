# List issue GitHub

The script returns a .csv file with the issues from a GitHub repository.

### Requirements
To use the script you, only need to have installed [brew](https://brew.sh/) on your system.

### Usage
You can launch this script in two ways:
- Launch it without any parameters and the script will ask you how many issues you want to download, the state of the issues you desire (open, closed, or all), and the location of the GitHub repo in the filesystem.
> ./list_issue_github.sh
- Launch it with 3 parameters: first, how many issues you want to download; second, the state of the issues you desire (open, closed, or all) and, last, the location of the GitHub repo in the filesystem.
> ./list_issue_github.sh 4 all /home/mario/dev/super_mario_world_GitHub_repo

N.B. The script will download the most recent issues for the repo.

During the execution, if you want, you can choose to filter by label. You can only choose one label.

The .csv file returned can be imported into Google Sheets without any manipulation