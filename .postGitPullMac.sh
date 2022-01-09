# Set the local variables

LOCAL_DB_NAME="apex_webengage_wp"

OLD_URL="https://webengage.apexdivision.com"
NEW_URL="https://wp.webengage.test"

OLD_ESCAPED_URL="https:\/\/webengage.apexdivision.com"
NEW_ESCAPED_URL="https:\/\/wp.webengage.test"



# This will probably never change, but still, just in case
LOCAL_DB_USER="projects"
LOCAL_DB_PASS="projects"



######## Flush Local DB Tables

echo; echo;
echo "Flush local DB ${LOCAL_DB_NAME}"

# Random temp file name to create drop statements
RANDOM_FLUSH_SQL_FILE_NAME=$(echo $RANDOM | md5sum | head -c 10)

# Create drop statements
echo "SET FOREIGN_KEY_CHECKS = 0;" > ./${RANDOM_FLUSH_SQL_FILE_NAME}
mysqldump --add-drop-table --no-data -u ${LOCAL_DB_USER} -p${LOCAL_DB_PASS} ${LOCAL_DB_NAME} | grep 'DROP TABLE' >> ./${RANDOM_FLUSH_SQL_FILE_NAME}
echo "SET FOREIGN_KEY_CHECKS = 1;" >> ./${RANDOM_FLUSH_SQL_FILE_NAME}

# Execute
mysql -u ${LOCAL_DB_USER} -p${LOCAL_DB_PASS} ${LOCAL_DB_NAME} < ./${RANDOM_FLUSH_SQL_FILE_NAME}

# Drop the temp file
rm -rf ./${RANDOM_FLUSH_SQL_FILE_NAME}

echo "Done Flushing local DB ${LOCAL_DB_NAME}"
sleep 1







######## Import Local DB Tables from .db folder sql file

echo; echo;
echo "Import .db/${LOCAL_DB_NAME}.sql to local DB ${LOCAL_DB_NAME}"

mysql ${LOCAL_DB_NAME} < .db/${LOCAL_DB_NAME}.sql -u ${LOCAL_DB_USER} -p${LOCAL_DB_PASS}

echo "Done Importing to local DB ${LOCAL_DB_NAME}"
sleep 1







######## Change Normal URLs in the DB

echo; echo;
echo "Change Normal ${OLD_URL} to ${NEW_URL}"

php wp search-replace ${OLD_URL} ${NEW_URL}

echo "Done Changing Normal URLs"
sleep 1







######## Change Escaped URLs in the DB

echo; echo;
echo "Change Escaped ${OLD_ESCAPED_URL} to ${NEW_ESCAPED_URL}"

php wp search-replace ${OLD_ESCAPED_URL} ${NEW_ESCAPED_URL}  --all-tables

echo "Done Changing Escaped URLs"
sleep 1



echo; echo;
echo "Post Git Pull adjustments done!"



