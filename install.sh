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

if [[ "$INST" == "n" ]]; then
	echo "Instalação cancelada!"
	exit 1
fi

# Checando se os parâmetros foram passados corretamente e se existe o repositório do Oracle.
YUMREPO=$(ls /etc/yum.repos.d)
if [[ -z "${YUMREPO}" ]]; then
	echo "#########################################"
	echo "Arquivo de repositório não encontrado."
	echo "Verifique no diretório: /etc/yum.repos.d/"
	echo "#########################################"
	exit 1
fi

if [[ -z "${VERORA}" ]]; then
	echo "Você não passou a versão do S.O como parâmetro!"
	echo "Ex: ./install 5 11 //para o caso de a versão do S.O ser 5 e do banco 11"
	exit 1
fi

if [[ -z "${VERDB}" ]]; then
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

# Criando usuários
echo ""
echo "Criando usuários 'oracle' e 'grid'"
echo ""
groupadd -g 1000 oinstall
groupadd -g 1020 asmadmin
groupadd -g 1021 asmdba
groupadd -g 1031 dba
groupadd -g 1022 asmoper
useradd -u 1100 -g oinstall -G asmadmin,asmdba,dba grid
useradd -u 1102 -g oinstall -G dba,asmdba oracle
echo "Usuários criados!"
echo ""
echo "## Definindo senha de usuários ##"
passwd oracle
passwd grid

# Desabilitando serviços e setando os parâmetros
echo ""
echo "Desabilitando serviços, como IPv6"
echo ""
if [[ "$VERORA" == "5" ]] || [[ "$VERORA" == "6" ]]; then
	chkconfig iptables off
	chkconfig ip6tables off
	service iptables stop
	service ip6tables stop
	chkconfig auditd off
	chkconfig restorecond off
	chkconfig netfs on
	chkconfig --level 35 nscd on
	service nscd start
elif [[ "$VERORA" == "7" ]]; then
	systemctl stop firewalld
	systemctl disable firewalld
	systemctl start sshd.service
	systemctl enable sshd.service
fi

echo ""
echo "Verificando SELINUX..."
SELINUX=$(awk '/SELINUX=/ {print $1}' /etc/selinux/config |grep -i "^SELINUX=")
if [[ "$SELINUX" != "SELINUX=disabled" ]]; then
	sed -i -e 's/'$SELINUX'/SELINUX=disabled/g' /etc/selinux/config
	echo "Selinux foi alterado para 'disabled'."
else
	echo "Selinux já está desativado."
fi

echo ""
echo "Inserindo parâmetros em /etc/sysctl.conf para versão Oracle Database "$VERDB"."
if [[ "$VERDB" == "11" ]]; then
	echo "fs.aio-max-nr=1048576
fs.file-max=6815744
kernel.shmmni=4096
kernel.sem=250 32000 100 128
net.ipv4.ip_local_port_range=9000 65500
net.core.rmem_default=262144
net.core.rmem_max=4194304
net.core.wmem_default=262144
net.core.wmem_max=1048586

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
	echo "Inserido com sucesso!"
fi

if [[ "$VERDB" == "10" ]]; then
	echo "Parâmetros do 10"
	echo "Inserido com sucesso!"
fi

if [[ "$VERDB" == "12" ]]; then
	echo "Parâmetros do 12"
	echo "Inserido com sucesso!"
fi

echo ""
echo "Inserindo parâmetros em /etc/security/limits.conf para versão Oracle Database "$VERDB"."
MEMKB=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
read -p "Memória total do servidor é $MEMKB kB, defina o valor apropriado para 'memlock': " MEMLOCK
if [[ "$VERDB" == "11" ]]; then
		echo "oracle soft nofile 1024
oracle hard nofile 65536
oracle soft nproc 2047
oracle hard nproc 16384
oracle soft stack 10240
oracle hard stack 32768
oracle hard memlock $MEMLOCK
oracle soft memlock $MEMLOCK

grid soft nproc 16384
grid hard nproc	16384
grid soft nofile 10240
grid hard nofile 65536" >> /etc/security/limits.conf
	echo "Inserido com sucesso!"
fi

if [[ "$VERDB" == "10" ]]; then
	echo "Parâmetros do 10"
	echo "Inserido com sucesso!"
fi

if [[ "$VERDB" == "12" ]]; then
	echo "Parâmetros do 12"
	echo "Inserido com sucesso!"
fi