#!/bin/bash

REALM=TEST.COM
PRINC_APPEND=${REALM}

# bdoc admin keytab file
PRINC_ADMIN=bdoc/admin@${REALM}
KEYTAB_PATH=/home/bdoc/data/keytab/
KEYTAB_NAME=bdoc.keytab

# generate keytab for users
SERV=/bdoc

DATE=$(date +%y%m%d)
LOG_FILE=/var/log/ker_bdoc_$DATE.log
OUT=/var/log/ker_bdoc_$DATE.out
ERR=/var/log/ker_bdoc_$DATE.err

# exec 1>>$OUT
# exec 2>>$ERR

help() {
	cat<<__EOF__
	usage: bdockrb [ list | keytab_randkey | delkeytab | help ]
	
	example:
		bdockrb list				# list all the principals in db
		bdockrb keytab_randkey user		# add a principal in db and generate a keytab include it
		bdockrb delkeytab user 			# delete the user's principal in db and remove its keytab
__EOF__
}

function list() {
	kadmin -kt ${KEYTAB_PATH}${KEYTAB_NAME} -p ${PRINC_ADMIN} -q \
	"listprincs"
}

addprinc_with_passwd() {
	user_name=$1
	echo "add for $user_name" # >> $LOG_FILE
	PRINC=${user_name}${SERV}@${REALM}

	echo "keytab path: ${KEYTAB_PATH}" # >> $LOG_FILE
	echo "keytab name: ${KEYTAB_NAME}" # >> $LOG_FILE
	echo "use princ: ${PRINC_ADMIN}" # >> $LOG_FILE
	echo "created princ: ${PRINC}" # >> $LOG_FILE

	kadmin -kt ${KEYTAB_PATH}${KEYTAB_NAME} -p ${PRINC_ADMIN} -q \
	"addprinc -pw $2 ${PRINC}"
	
}

addprinc_with_randkey() {
	user_name=$1
	echo "add for $user_name" # >> $LOG_FILE
	PRINC=${user_name}${SERV}@${REALM}

	echo "keytab path: ${KEYTAB_PATH}" # >> $LOG_FILE
	echo "keytab name: ${KEYTAB_NAME}" # >> $LOG_FILE
	echo "use princ: ${PRINC_ADMIN}" # >> $LOG_FILE
	echo "created princ: ${PRINC}" # >> $LOG_FILE

	kadmin -kt ${KEYTAB_PATH}${KEYTAB_NAME} -p ${PRINC_ADMIN} -q \
	"addprinc -randkey ${PRINC}"
	echo "exit: $?"
}

gen_keytab() {
	username=$1
	user_principal=${username}${SERV}@$REALM
	keytab_file=${username}.keytab
	echo "keytab_file: ${keytab_file}"
	echo "principal is $user_principal"
	echo "${username} keytab file is : ${username}.keytab" # >> $LOG_FILE

	kadmin -kt ${KEYTAB_PATH}${KEYTAB_NAME} -p ${PRINC_ADMIN} -q \
	"ktadd -k ${KEYTAB_PATH}${keytab_file} ${user_principal}"
	echo "exitcode: $?"
}

del_keytab() {
	user_name=$1
	rm ${KEYTAB_PATH}${user_name}.keytab
	PRINC=${user_name}${SERV}@${REALM}
	echo "principal: ${PRINC}" # >> $LOG_FILE
	echo yes | kadmin -kt ${KEYTAB_PATH}${KEYTAB_NAME} -p ${PRINC_ADMIN} -q \
	"delprinc ${PRINC}"
}

case "$1" in
	list)
		list
		exit $?
		;;
	keytab_randkey)
		# if [ -z "$2" ]; then
		if [ x"$2" = x ]; then
			exit 1
		fi
		addprinc_with_randkey $2
		gen_keytab $2
		exit $?
		;;
	delkeytab)
		# if [ -z "$2" ]; then
		if [ x"$2" = x ]; then
			exit 1
		fi
		del_keytab $2
		exit $?
		;;
	help)
		help
		;;
		
	*)
		help
		echo "error command"
		exit 1
		;;
esac
