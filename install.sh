#!/bin/bash

# Parâmetros: Versão do S.O & Versão do banco.
VERORA=$1
VERDB=$2

echo ""
echo "## Verificações antes de prosseguir:"
echo "- Verifique se o arquivo /etc/yum.repos.d/public-yum-ol"$VERORA".repo existe. Se sim, confirme se a"
echo "versão correta de atualização está descomentada, comente o que não precisa ser atualizado."
echo "--------------"
echo "Você definiu a versão do S.O como Oracle Linux "$VERORA" e do banco como Oracle Database "$VERDB"."
read -p "Deseja continuar com a instalação? (s/n): " INST

if [ "$INST" == "n" ]; then
	exit 1
fi

# Checando se os parâmetros foram passados corretamente e se existe o repositório do Oracle.
YUMREPO=$(ls /etc/yum.repos.d)
if [ -z "${YUMREPO}" ]; then
	echo "#########################################"
	echo "Arquivo de repositório não encontrado."
	echo "Verifique no diretório: /etc/yum.repos.d/"
	echo "#########################################"
	exit 1
fi

if [ -z "${VERORA}" ]; then
	echo "Você não passou a versão do S.O como parâmetro!"
	echo "Ex: ./install 5 11 //para o caso de a versão do S.O ser 5 e do banco 11"
	exit 1
fi

if [ -z "${VERDB}" ]; then
	echo "Você não passou a versão do banco como parâmetro!"
	echo "Ex: ./install 5 11 //para o caso de a versão do S.O ser 5 e do banco 11"
	exit 1
fi

# Instalando pacotes iniciais
echo "## Instalando pacotes e executando UPDATE ##"
yum -y install unzip
yum -y install ntp
yum -y install binutils-2*x86_64*
yum -y install glibc-2*x86_64* nss-softokn-freebl-3*x86_64*
yum -y install glibc-2*i686* nss-softokn-freebl-3*i686*
yum -y install compat-libstdc++-33*x86_64*
yum -y install compat-libstdc++*
yum -y install compat-libcap1
yum -y install glibc-common-2*x86_64*
yum -y install glibc-devel-2*x86_64*
yum -y install glibc-devel-2*i686*
yum -y install glibc-headers-2*x86_64*
yum -y install elfutils-libelf-0*x86_64*
yum -y install elfutils-libelf-devel-0*x86_64*
yum -y install gcc-4*x86_64*
yum -y install gcc-c++-4*x86_64*
yum -y install gcc
yum -y install gcc-c++
yum -y install ksh-*x86_64*
yum -y install libaio-0*x86_64*
yum -y install libaio-devel-0*x86_64*
yum -y install libaio-0*i686*
yum -y install libaio-devel-0*i686*
yum -y install libgcc-4*x86_64*
yum -y install libgcc-4*i686*
yum -y install libstdc++-4*x86_64*
yum -y install libstdc++-4*i686*
yum -y install libstdc++-devel-4*x86_64*
yum -y install libstdc++-devel.i686
yum -y install make-3.81*x86_64*
yum -y install numactl-devel-2*x86_64*
yum -y install sysstat-9*x86_64*
yum -y install compat-libstdc++-33*i686*
yum -y install compat-libcap*
yum -y install autofs
yum -y install nscd
yum -y install xorg-x11-xauth
yum -y install xorg-x11-apps
yum -y install xorg-x11-utils
yum install oracleasm-support
yum update

# Desabilitando serviços e setando os parâmetros
echo "Desabilitando serviços, como IPv6"
if [ "$VERORA" == "5" ] || [ "$VERORA" == "6" ]; then
	chkconfig iptables off
	chkconfig ip6tables off
	service iptables stop
	service ip6tables stop
	chkconfig auditd off
	chkconfig restorecond off
	chkconfig netfs on
	chkconfig --level 35 nscd on
	service nscd start
else
	systemctl stop firewalld
	systemctl disable firewalld
	systemctl start sshd.service
	systemctl enable sshd.service
fi

echo "Verificando SELINUX..."
SELINUX=$(awk '/SELINUX=/ {print $1}' /etc/selinux/config |grep -o 'disabled')
if [ "$SELINUX" == "disabled" ]; then
	echo "Selinux marcado como DISABLED."
else
	echo "Selinux está ativo, troque o parâmetro no arquivo: /etc/selinux/config"
	echo "Alterando o valor de SELINUX={enforcing|permissive} para {disabled}."
	echo "SELINUX=disabled"
	echo "Prossiga com a instalação quando o arquivo for alterado."
	echo ""
	read -p "Deseja prosseguir? (s/n): " SEL
	if [ "$SEL" == "n" ]; then
		exit 1
	fi
fi