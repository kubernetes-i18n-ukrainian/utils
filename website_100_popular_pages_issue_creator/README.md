# Website 100 popular pages issue creator

This script automaticaly create issues in your repo. [Example](https://github.com/kubernetes-i18n-ukrainian/website/milestone/1)

## Requrements
1. bash 4+
2. hub https://github.com/github/hub
3. `GITHUB_TOKEN` with access to repo. [How create](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line#creating-a-token)
4. `export GITHUB_TOKEN` to env
5. Copy `create_issues.sh` and `location` files to root of your `website` fork
6. Set settings in `create_issues.sh`
7. Create milestone and label in your repo if needed.
8. Run `bash create_issues.sh`
