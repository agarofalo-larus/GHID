# List issue GitHub

The script returns a .csv file with the issues from a GitHub repository.

### Requirements
To use the script you, only need to have installed [brew](https://brew.sh/) on your system.

### Usage
You can launch this script using those options (and combine them):
- You must declare the absolute path where the GitHub repo is located using the `-p` option. This option is mandatory.
> ./list_issue_github.sh -p /home/mario/dev/super_mario_world_GitHub_repo_dir
- You can filter by label using the `-l` option.
> ./list_issue_github.sh -l enhancement -p /home/mario/dev/super_mario_world_GitHub_repo_dir
- You can filter by status using the `-s` option. If you are not specifying a status the script will use the default value `all`
> ./list_issue_github.sh -s closed -p /home/mario/dev/super_mario_world_GitHub_repo_dir
- You can take the last n issues using the `-n` option. If you are not specifying a quantity the script will use the default value `20`
> ./list_issue_github.sh -n 10 -p /home/mario/dev/super_mario_world_GitHub_repo_dir
- You view the list of the valid options using `-h` option.
> ./list_issue_github.sh -h

This is a complete example using all the options:
> ./list_issue_github.sh -l blocked -s open -n 50 -p /home/luigi/dev/luigis_mansion_GitHub_repo_dir

N.B. The script will download the most recent issues for the repo.

The .csv file returned can be imported into Google Sheets without any manipulation