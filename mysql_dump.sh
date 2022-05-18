#!/bin/bash

MYSQL_USER=__BACKUP__USER
MYSQL_PASS=__BACKUP__PASS
MYSQL_DUMP_PARAMETERS="--all-databases"
MYSQL_DUMP_SCHEMA_PARAMETERS="--routines --triggers --events --no-data "
MYSQL_DUMP_DATA_PARAMETERS="--routines --events --triggers --no-create-info --no-create-db --single-transaction "

MYSQL_DUMP_TYPE=$1

# Defina abaixo o path para onde o backup será armazenado
DIFFDIR=/mnt/BACKUP/BASES_NOVO/diff

# Defina abaixo uma nomeclatura util para o servidor, aqui usaremos SERVIDOR_IP
SERVIDOR_NOME="SERVER_NAME_AND_SERVER_IP"

# Altere o ip abaixo para o ip do servidor em quest
SERVIDOR_IP="127.0.0.1"

MYMODULO="sql"

exec_limpeza(){
	# Funcao para limpeza de arquivos mais velhos

	RETENCAO=$1
	DIFFDIR=$2 
	SERVIDOR=$3
		
	DAYSD=`date +%d -d "$RETENCAO day ago"`
	DAYSY=`date +%Y -d "$RETENCAO day ago"`
	DAYSM=`date +%m -d "$RETENCAO day ago"`


	if [ -d $DIFFDIR/$DAYSY/$DAYSM/$DAYSD/$SERVIDOR ]; then 
		echo "Executando limpeza do diretorio : ${DIFFDIR}/${DAYSY}/${DAYSM}/${DAYSD}/${SERVIDOR}"
		rm -rf ${DIFFDIR}/${DAYSY}/${DAYSM}/${DAYSD}


	fi


}



# definincao da retencao
RETENCAO=5

exec_limpeza $RETENCAO $DIFFDIR $SERVIDOR_NOME

exec_mysql_d_full(){

	if [ ! -d $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR_NOME/$MYMODULO ]; then

		mkdir -p $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR_NOME/$MYMODULO
		echo "Criado Diretorio: $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR_NOME/$MYMODULO"
	fi


	echo "[$(date)] Dumping database start: ALL_DATABASES"
	/usr/bin/mysqldump -u${MYSQL_USER} -p${MYSQL_PASS} -h${SERVIDOR_IP} ${MYSQL_DUMP_PARAMETERS} > $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR_NOME/$MYMODULO/database.sql
	/usr/bin/gzip $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR_NOME/$MYMODULO/database.sql
	echo "[$(date)] Dumping database finish: ALL_DATABASES"

}

exec_mysql_d_databases(){
	if [ ! -d $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR_NOME/$MYMODULO ]; then
                
                mkdir -p $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR_NOME/$MYMODULO
                echo "Criado Diretorio: $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR_NOME/$MYMODULO"
        fi

	for DATABASES in $(/usr/bin/mysql -u${MYSQL_USER} -p${MYSQL_PASS} -h${SERVIDOR_IP} -e "show databases" | sed 1d); do
		echo "[$(date)] Dumping database start: $DATABASES"
		/usr/bin/mysqldump -u${MYSQL_USER} -p${MYSQL_PASS} -h${SERVIDOR_IP} --databases ${DATABASES} ${MYSQL_DUMP_SCHEMA_PARAMETERS} > $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR_NOME/$MYMODULO/${DATABASES}_schema.sql
		/usr/bin/mysqldump -u${MYSQL_USER} -p${MYSQL_PASS} -h${SERVIDOR_IP} --databases ${DATABASES} ${MYSQL_DUMP_DATA_PARAMETERS} > $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR_NOME/$MYMODULO/${DATABASES}_data.sql
        	/usr/bin/gzip $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR_NOME/$MYMODULO/${DATABASES}_schema.sql
        	/usr/bin/gzip $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR_NOME/$MYMODULO/${DATABASES}_data.sql
		echo "[$(date)] Dumping database finish: $DATABASES"

	done
}

case $MYSQL_DUMP_TYPE in
	'FULL')
		exec_mysql_d_full
	;;
	'DATABASES')
		exec_mysql_d_databases
	;;
	'*')
		echo "Utilize mysql_dump.sh [FULL|DATABASES]"
	;;
esac
