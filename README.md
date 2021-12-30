# git-backup


## Step 1: Disallow listing (indexing) of dot files / folder

Add the below lines in .htaccess in web-root

```
# Disallow listing (indexing) of dot files / folder
<IfModule mod_rewrite.c>
RewriteEngine on
RewriteCond %{THE_REQUEST} ^.*/\.
RewriteRule ^(.*)$ - [R=404]
</IfModule>
```

## Step 2: Create variable file

Create **.git-variables** in web-root as per sample in this git

```
# Run Mode, development or backup
RUN_MODE="development"

# Put Git PAT Name, like: Apex Live
GIT_PAT_NAME="Apex Live"

# Git Full url, with username and password like https://username:password@github.com/username/repository.git
GIT_URL="https://username:password@github.com/username/repository.git"

GIT_CD_PATH="PATH"

# Whether to backup mysql DBs or not, 1 or 0
GIT_BACKUP_DB=0

# Below DB credentials only if GIT_BACKUP_DB = 1
# Set as per requirement, if more than one DB to be backed up, use GIT_MYSQL_2 and so on
# IMP :::: Make sure to update GIT_MYSQL_MAX_INDEX with number of DBs to be backed up
# GIT_MYSQL_1=("user_1" "pass_1" "db_1" "localhost" "3306")
# GIT_MYSQL_MAX_INDEX=1


# Default settings, can be overridden as well, after the if blocks
if [[ $RUN_MODE == 'backup' ]]; then
    DELETE_DB=1
    DELETE_GIT=1
    GIT_PULL=0
fi

if [[ $RUN_MODE == 'development' ]]; then
    DELETE_DB=0
    DELETE_GIT=0
    GIT_PULL=1
fi
```

## Step 3: Run, manually or by cron

Optional argument '1' for Manual mode. It just changes the commit message

```
./.gitBackupInit.sh
```

## TODO:
* Pass optional commit message
