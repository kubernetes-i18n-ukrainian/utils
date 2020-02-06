
#
# This script automaticaly create issues in your repo.
# Example: https://github.com/kubernetes-i18n-ukrainian/website/milestone/1
#
# Requrements:
# 1. bash 4+
# 2. hub https://github.com/github/hub
# 3. GITHUB_TOKEN with access to repo https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line#creating-a-token
# 4. `export GITHUB_TOKEN` to env
# 5. Copy `create_issues.sh` and `location` files to root of your `website` fork
# 6. Set settings in `create_issues.sh`
# 7. Create milestone and label in your repo if needed.
# 8. Run `bash create_issues.sh`
#

##################
# SETTINGS START #
##################

ORIG_LANG=en
DEST_LANG=uk
FORK_REPO_AND_BRANCH="https://github.com/kubernetes-i18n-ukrainian/website/tree/master"
MILESTONE="Translate 100 most popular pages"
LABEL="new content"

##################
## SETTINGS END ##
##################

function find_files {
  ##### Params #####
  LOCATION=$1
  EXTENTION=${2-""}
  ### Params end ###

  find content/en${LOCATION}${EXTENTION} -maxdepth 1 -type f 2>/dev/null
}

function find_dir {
  ##### Params #####
  LANG=$1
  LOCATION=$2
  EXTENTION=${3-""}
  ### Params end ###

  dirname "content/${LANG}${LOCATION}${EXTENTION}"
}


while read p; do
  POPULARITY_NUM=$(echo $p | awk '{print $1}')
  LOCATION=$(echo $p | awk '{print $2}')
  echo $POPULARITY_NUM

  # Markdown file
  if [[ $(find_files $LOCATION .md) ]]; then
    DEST_DIR=$(find_dir $DEST_LANG $LOCATION .md)
    ORIG_DIR=$(find_dir $ORIG_LANG $LOCATION .md)

    CP_COMMAND=$(echo "mkdir -p $DEST_DIR && cp ${ORIG_DIR}${LOCATION}.md $ORIG_DIR/_index.md $DEST_DIR")

    SIZE=$(echo "content/en${LOCATION}.md $ORIG_DIR/_index.md" | xargs cat | wc -c)

  # HTML file
  elif [[ $(find_files $LOCATION .html) ]]; then
    DEST_DIR=$(find_dir $DEST_LANG $LOCATION .html)
    ORIG_DIR=$(find_dir $ORIG_LANG $LOCATION .html)

    CP_COMMAND=$(echo "mkdir -p $DEST_DIR && cp ${ORIG_DIR}${LOCATION}.html $ORIG_DIR/_index.md $DEST_DIR")

    HTML=$(cat content/en${LOCATION}.html | wc -c)
    MD=$(cat $ORIG_DIR/_index.md | wc -c)
    SIZE=$((HTML/2 + MD))

  # Dir with files
  elif [[ $(find_files $LOCATION) ]]; then
    DEST_DIR=$(find_dir $DEST_LANG $LOCATION)
    ORIG_DIR=$(find_dir $ORIG_LANG $LOCATION)

    CP_COMMAND=$(echo "mkdir -p ${DEST_DIR} && find ${ORIG_DIR} -maxdepth 1 -type f | xargs -I{} cp -u {} $DEST_DIR")

    SIZE=$(find ${ORIG_DIR} -maxdepth 1 -type f | xargs cat | wc -c)
  fi


  # Prepare Issue
  ISSUE_NAME="Localize '${LOCATION}' path"
  ISSUE_BODY="* Location popularity: ${POPULARITY_NUM}/100
* Site path: https://kubernetes.io${LOCATION}
* Git \`${ORIG_LANG}\` dir path: ${FORK_REPO_AND_BRANCH}/${ORIG_DIR}
* Copy file(s) to \`${DEST_LANG}\`: \`${CP_COMMAND}\`
"

  if (( $SIZE < 500 )); then
    SIZE_LABEL="size/XS"
  elif (( $SIZE < 1500 )); then
    SIZE_LABEL="size/S"
  elif (( $SIZE < 5000 )); then
    SIZE_LABEL="size/M"
  elif (( $SIZE < 25000 )); then
    SIZE_LABEL="size/L"
  elif (( $SIZE < 50000 )); then
    SIZE_LABEL="size/XL"
  else
    SIZE_LABEL="size/XXL"
  fi

  # Create Issue
  hub issue create -m "${ISSUE_NAME}" -m "${ISSUE_BODY}" --milestone "Translate 100 most popular pages" -l "new content,${SIZE_LABEL}"

done <locations
