for HOST in ${MYSQL_SERVERS}
do
  mkdir -p "${BACKUPDIR}/${HOST}"

  # Get list of databases
  DATABASES=$(mysql -u ${BACKUP_USER} -p${BACKUP_PASSWORD} -h ${HOST} --connect-timeout=10 -Ns -e 'show databases' 2>/dev/null || echo '')

  # Backup list of databases
  for DATABASE in ${DATABASES}
  do
    case ${DATABASE} in
      'information_schema' | 'performance_schema'| 'mysql'| 'innodb'| 'tmp' | 'sys')
        echo "Skipping backup of ${DATABASE}"
        ;;
      'lost+found' )
        echo "Skipping ${DATABASE}, which is not a MySQL database"
        ;;
      * )
        mysqldump -u ${BACKUP_USER} -p${BACKUP_PASSWORD} -h ${HOST} --events --routines --single-transaction --databases ${DATABASE} | gzip > ${BACKUPDIR}/${HOST}/${DATABASE}-$(date -Iseconds).sql.gz
        ;;
      esac
    done
done
