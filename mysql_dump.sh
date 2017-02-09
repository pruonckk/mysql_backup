#!/bin/bash

MYSQL_USER=root
MYSQL_PASS=SUA_SENHA
MYSQL_DUMP_PARAMETERS="--all-databases"

MYSQL_DUMP_TYPE=$1

DIFFDIR=/home/backup
SERVIDOR=`hostname`

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


case $MYSQL_DUMP_TYPE in
	'FULL')
		exec_mysql_d_full
	;;
	'DATABASES')
		exec mysql_d_databases
	;;
esac

# definincao da retencao
RETENCAO=15

exec_limpeza $RETENCAO $DIFFDIR $SERVIDOR

exec_mysql_d_full(){

	if [ ! -d $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR/$MYMODULO ]; then

		mkdir -p $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR/$MYMODULO
		echo "Criado Diretorio: $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR/$MYMODULO"
	fi


	/usr/bin/mysqldump -u${MYSQL_USER} -p${MYSQL_PASS} ${MYSQL_DUMP_PARAMETERS} > $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR/$MYMODULO/database.sql
	/usr/bin/gzip $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR/$MYMODULO/database.sql

}

exec_mysql_d_databases(){
	if [ ! -d $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR/$MYMODULO ]; then
                
                mkdir -p $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR/$MYMODULO
                echo "Criado Diretorio: $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR/$MYMODULO"
        fi

	for DATABASESES in $(/usr/bin/mysql -u${MYSQL_USER} -p${MYSQL_PASS} -e "show databases" | sed 1d); do
		echo "Dumping database: $DATABASES"
		/usr/bin/mysqldump -u${MYSQL_USER} -p${MYSQL_PASS} --database ${DATABASES} > $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR/$MYMODULO/$DATABASES}.sql
        	/usr/bin/gzip $DIFFDIR/$(date +%Y)/$(date +%m)/$(date +%d)/$SERVIDOR/$MYMODULO/${DATABASES}.sql

	done
}


