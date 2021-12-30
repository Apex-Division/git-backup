#!/bin/bash
# Backup Init script
# V 1.0

# Font colours, something fancy!
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

NC='\033[0m'




# Include the .git-variables file, if not found, it will automatically quit
echo -e "${RED}Include the .git-variables file, if not found, it will automatically quit${NC}"; echo;
. .git-variables


# Max Generated SQL File Size, it bytes, 20 MB
MAX_SIZE_SQL_SIZE=20971520

DATE_STAMP=$(date '+%d %b, %Y %H:%M %Z')
echo -e "${RED}Date Time Stamp is: ${DATE_STAMP}${NC}"
echo



# Change path
echo -e "${CYAN}Change path to ${GIT_CD_PATH}${NC}"
echo
cd "${GIT_CD_PATH}"




# Delete .db files
if [[ $GIT_DELETE_DB == '1' ]]; then
    # Delete current DB files
    echo -e "${CYAN}Delete existing DB files, if any${NC}"
    echo
    rm -rf .db
fi




# DB Backup section
if [ "$GIT_BACKUP_DB" -eq "1" ]; then
  echo -e "${CYAN}Backup MySQL DBs${NC}"
  echo


  # Create .db folder, if not there
  mkdir -p .db

  for ((i = 1; i <= ${GIT_MYSQL_MAX_INDEX}; i++)); do
    echo -e "${RED}DB: ${i}${NC}"

    mysql_user="GIT_MYSQL_$i[0]"
    mysql_pass="GIT_MYSQL_$i[1]"
    mysql_db="GIT_MYSQL_$i[2]"
    mysql_host="GIT_MYSQL_$i[3]"
    mysql_port="GIT_MYSQL_$i[4]"

    mysql_sql="${!mysql_db}.sql"

    echo -e "Back up ${DARKGRAY}${!mysql_db}${NC} from ${DARKGRAY}${!mysql_host}${NC} using user: ${DARKGRAY}${!mysql_user}${NC} to ${DARKGRAY}.db/${mysql_sql}${NC}"

    if [ "${!mysql_host}" == "localhost" ] || [ "${!mysql_host}" == "127.0.0.1" ]; then
      mysqldump --add-drop-table --no-tablespaces --single-transaction ${GIT_MYSQL_EXTENDED_INSERT} "${!mysql_db}" -u "${!mysql_user}" -p"${!mysql_pass}" >".db/${mysql_sql}"
    else
      mysqldump --add-drop-table --no-tablespaces --single-transaction ${GIT_MYSQL_EXTENDED_INSERT} --protocol=TCP -h "${!mysql_host}" --port="${!mysql_port}" "${!mysql_db}" -u "${!mysql_user}" -p"${!mysql_pass}" >".db/${mysql_sql}"
    fi


    if [[ $OSTYPE == 'darwin'* ]]; then
      sql_filesize=$(stat -f %z ".db/${mysql_sql}")
    else
      sql_filesize=$(stat -c%s ".db/${mysql_sql}")
    fi

    echo "Size of .db/${mysql_sql} = $sql_filesize bytes."

    if ((sql_filesize > MAX_SIZE_SQL_SIZE)); then


      if ((GIT_MYSQL_COMPRESS == 1)); then

        echo -e "${RED}SQL File is larger than 20 MB, compress to ${DARKGRAY}.db/${mysql_sql}.tgz${NC}"
        cd ".db"
        tar cpzf "${mysql_sql}.tgz" "${mysql_sql}"
        rm -rf "${mysql_sql}"


        #      Check .tgz file size and if large, split and delete .tgz file
        if [[ $OSTYPE == 'darwin'* ]]; then
          tgz_filesize=$(stat -f %z "${mysql_sql}.tgz")
        else
          tgz_filesize=$(stat -c%s "${mysql_sql}.tgz")
        fi

        echo "Size of .db/${mysql_sql}.tgz = $tgz_filesize bytes."

        if ((sql_filesize > MAX_SIZE_SQL_SIZE)); then
          echo -e "${RED}Compressed File is larger than 20 MB, split to ${DARKGRAY}.db/${mysql_sql}.tgz.parts.xx${NC}"

          # use gsplit for Mac (MacOS coreutils installed by brew or macport, otherwise use normal GNU split)
          if [[ $OSTYPE == 'darwin'* ]]; then
            # TODO use MacOS split syntax
            gsplit --verbose -b10M "${mysql_sql}.tgz" "${mysql_sql}.tgz.parts."
          else
            split --verbose -b10M "${mysql_sql}.tgz" "${mysql_sql}.tgz.parts."
          fi

          # Delete the original .tgz file
          rm -rf "${mysql_sql}.tgz"
        fi

      else

        echo -e "${RED}SQL File is larger than 20 MB, split it ${NC}"
        cd ".db"

        # use gsplit for Mac (MacOS coreutils installed by brew or macport, otherwise use normal GNU split)
        if [[ $OSTYPE == 'darwin'* ]]; then
          # TODO use MacOS split syntax
          gsplit --verbose -b10M "${mysql_sql}" "${mysql_sql}.parts."
        else
          split --verbose -b10M "${mysql_sql}" "${mysql_sql}.parts."
        fi

        # Delete the original .sql file
        rm -rf "${mysql_sql}"

      fi


      cd ..

    fi

  done

fi





if [[ $GIT_DELETE_GIT == '1' ]]; then
  rm -rf .git
fi





# create temp folder, go inside, git clone, come out, delete temp folder, if .git folder is not found

if [ ! -f .git ]; then

  # Random folder name for git clone
  RANDOM_FOLDER_NAME=$(echo $RANDOM | md5sum | head -c 10)

  # Create the random folder
  mkdir -p $RANDOM_FOLDER_NAME
  echo -e "${RED}Created Random folder: ${RANDOM_FOLDER_NAME} for git clone${NC}"

  # go inside random folder, git clone GIT_URL
  echo -e "${RED}Go inside git clone random folder${NC}"
  cd "$RANDOM_FOLDER_NAME"

  echo -e "${RED}git clone ${GIT_URL}${NC}"
  git clone "${GIT_URL}" .

  echo -e "${RED}Delete .git from outside, if any ${GIT_URL}${NC}"
  rm -rf ../.git

  echo -e "${RED}Move .git to outside${GIT_URL}${NC}"
  mv .git ../

  echo -e "${RED}Out of random folder${NC}"
  cd ..

# Delete the random folder
echo -e "${RED}Delete the random folder${NC}"
rm -rf "$RANDOM_FOLDER_NAME"

fi







### set git default options

# backup .gitignore file, if present
IGNORE_FILE=".gitignore"
if test -f "$IGNORE_FILE"; then
  rm -rf .gitignore_back_by_git_backup
  cp .gitignore .gitignore_back_by_git_backup
fi


# append to .gitignore or create one
  cat <<EOT >> .gitignore

.DS_Store
._.DS_Store
**/.DS_Store
**/._.DS_Store
.idea
.svn
Thumbs.db
.gitignore_back_by_git_backup
.git-variables

EOT


git config --unset credential.helper
git config --unset core.excludesfile

git config user.email "apexdivision@gmail.com"
git config user.name "Apex Division Auto Backup (.gitBackup Bot)"
git config init.defaultBranch main
git config pull.rebase false
git config -l





# git pull, only in development mdoe
if [[ $GIT_PULL == '1' ]]; then
  git status
  git pull
fi





# git routine, add, commit and push with status after each step
git status
git add -A
git commit -m "AUTO BACKUP (.gitBackup) - ${DATE_STAMP}"
git status
git push origin main
git status




# rollback .gitignore
rm -rf .gitignore
IGNORE_FILE=".gitignore_back_by_git_backup"
if test -f "$IGNORE_FILE"; then
    mv .gitignore_back_by_git_backup .gitignore
fi






if [[ $GIT_DELETE_DB == '1' ]]; then
  # Delete created DB files
  echo
  echo -e "${CYAN}Delete created DB files${NC}"
  rm -rf .db
fi



if [[ $GIT_DELETE_GIT == '1' ]]; then
  # Delete .git folder
  echo
  echo -e "${CYAN}Delete .git${NC}"
  rm -rf .git
fi



echo
echo -e "${GREEN}All Done at .gitBackup.sh${NC}"
echo
