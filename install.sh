#!/bin/bash

YUMREPO=$(ls /etc/yum.repos.d/*)
if [ -z "${YUMREPO}" ]; then
	echo "#########################################"
	echo "Arquivo de repositório não encontrado."
	echo "Verifique no diretório: /etc/yum.repos.d/"
	echo "#########################################"
fi