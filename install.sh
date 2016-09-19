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
echo ""
echo "Checando certificado de versões..."

if [[ "$VERDB" == "12" ]] && [[ "$VERORA" == "7" ]] || [[ "$VERORA" == "6" ]] || [[ "$VERORA" == "5" ]]; then
	echo "Versões certificadas, continuando instalação."
elif [[ "$VERDB" == "11" ]] && [[ "$VERORA" == "7" ]] || [[ "$VERORA" == "6" ]] || [[ "$VERORA" == "5" ]] || [[ "$VERORA" == "4" ]]; then
	echo "Versões certificadas, continuando instalação."
elif [[ "$VERDB" == "10" ]] && [[ "$VERORA" == "5" ]] || [[ "$VERORA" == "4" ]]; then
	echo "Versões certificadas, continuando instalação."
else
	echo "A instalação do Oracle Linux "$VERORA" juntamente com o Oracle Database "$VERDB", não é certificada pela Oracle."
	echo "Entre em contato com o DBA responsável pela instalação do ambiente para ignorar este requisito."
	echo "Instalação interrompida!"
	exit 1
fi

read -p "Deseja continuar com a instalação? (s/n): " INST

if [[ "$INST" == "n" ]] || [[ "$INST" == "N" ]]; then
	echo "Instalação cancelada!"
	exit 1
elif [[ "$INST" == "s" ]] || [[ "$INST" == "S" ]]; then
	echo "Prosseguindo com a instalação."
else
	echo "Opção inválida!"
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
yum -y install oracleasm-support
yum -y install compat-db-*
yum -y install binutils*
yum -y install control-center*
yum -y install glibc-*
yum -y install libstdc++-*
yum -y install pdksh-*
yum -y install sysstat-*
yum -y install libXp*
yum -y install xterm
yum -y update

echo ""
echo "@@@@@@@@@@@@@@@@@@@"
read -p "Gostaria de criar a estrutura de ASM? (s/n): " ASM
aa=0

while [[ aa == 0 ]]; do
	if [[ "$ASM" == "n" ]] || [[ "$ASM" == "N" ]]; then
		echo "Estrutura para ASM não será criada!"
		aa=1
	elif [[ "$ASM" == "s" ]] || [[ "$ASM" == "S" ]]; then
		echo "Preparando criação de estrutura ASM."
		aa=2
	else
		echo "Opção inválida!"
	fi
done

# Criando usuários
echo ""
echo "Criando usuários."
echo ""
if [[ "$VERDB" == "11" ]] || [[ "$VERDB" == "12" ]] && [[ aa == 2 ]]; then
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
	echo ""
	echo "Editando /etc/profile ..."
	echo"
if [ $USER = "oracle" ]; then
	if [ $SHELL = "/bin/ksh" ]; then
		ulimit -p 16384
		ulimit -n 65536
	else
		ulimit -u 16384 -n 65536
	fi
fi

# GRID
if [ $USER = "grid" ]; then
	if [ $SHELL = "/bin/ksh" ]; then
		ulimit -p 16384
		ulimit -n 65536
	else
		ulimit -u 16384 -n 65536 
	fi
fi" >> /etc/profile
	echo ""
	echo "Criando diretórios."
	mkdir -p  /u01/app/$VERDB.2.0/grid
	mkdir -p /u01/app/oracle/product/$VERDB.2.0/db_1
	chmod -R 775 /u01
	chown -R grid:oinstall /u01
	chown -R oracle:oinstall /u01/app/oracle
elif [[ "$VERDB" == "10" ]]; then
	groupadd -g 1021 asmdba
	groupadd -g 1000 oinstall
	groupadd -g 1031 dba
	useradd -u 1102 -g oinstall -G dba,asmdba oracle
	echo "Usuário Oracle criado!"
	echo ""
	echo "## Definindo senha de usuário ##"
	passwd oracle
	echo ""
	echo "Editando /etc/profile ..."
	echo"
if [ $USER = "oracle" ]; then
	if [ $SHELL = "/bin/ksh" ]; then
		ulimit -p 16384
		ulimit -n 65536
	else
		ulimit -u 16384 -n 65536
	fi
fi" >> /etc/profile
	echo ""
	echo "Criando diretórios."
	mkdir -p /u01/app/oracle/product/$VERDB.2.0/db_1
	chmod -R 775 /u01
	chown -R oracle:oinstall /u01
elif [[ "$VERDB" == "11" ]] || [[ "$VERDB" == "12" ]] && [[ aa == 1 ]]; then
	groupadd -g 1000 oinstall
	groupadd -g 1031 dba
	useradd -u 1102 -g oinstall -G dba oracle
	echo "Usuários criados!"
	echo ""
	echo "## Definindo senha de usuários ##"
	passwd oracle
	echo ""
	echo "Editando /etc/profile ..."
	echo"
if [ $USER = "oracle" ]; then
	if [ $SHELL = "/bin/ksh" ]; then
		ulimit -p 16384
		ulimit -n 65536
	else
		ulimit -u 16384 -n 65536
	fi
fi" >> /etc/profile
	echo ""
	echo "Criando diretórios."
	mkdir -p /u01/app/oracle/product/$VERDB.2.0/db_1
	chmod -R 775 /u01
	chown -R oracle:oinstall /u01
fi

# Desabilitando serviços e setando os parâmetros
echo ""
echo "Desabilitando serviços IPv6, IpTables, Auditd, Restorecond e subindo Netfs, NSCD, SSH."
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
if [[ "$VERDB" == "11" ]] || [[ "$VERDB" == "10" ]]; then
	echo "
fs.aio-max-nr=1048576
fs.file-max=6815744
kernel.shmmni=4096
kernel.sem=250 32000 100 128
net.ipv4.ip_local_port_range=9000 65500
net.core.rmem_default=262144
net.core.rmem_max=4194304
net.core.wmem_default=262144
net.core.wmem_max=1048586
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1" >> /etc/sysctl.conf
	sysctl -p /etc/sysctl.conf
	echo ""
	echo "Inserido com sucesso!"

elif [[ "$VERDB" == "12" ]]; then
	echo "fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 4294967295
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576" >> /etc/sysctl.conf
	/sbin/sysctl -p
	echo "Inserido com sucesso!"
fi

echo ""
echo "Inserindo parâmetros em /etc/security/limits.conf para versão Oracle Database "$VERDB"."
MEMKB=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
read -p "Memória total do servidor é $MEMKB kB, defina o valor apropriado para 'memlock': " MEMLOCK
echo "
oracle soft nofile 1024
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

# Configurações de rede
echo ""
echo ""
echo "#HOSTNAME#"
read -p "Digite o atual HOSTNAME do servidor: " HOSTNAME
read -p "Digite o atual IP do servidor: " IP

if [[ ! -z "${HOSTNAME}" ]] && [[ ! -z "${IP}" ]]; then
	echo "$IP 	$HOSTNAME" >> /etc/hosts
fi

# Download dos arquivos para o Oracle 11.2.0.4
function 11.2.0.4(){
	echo "Baixando OPatch de Julho/2016 para 11g."
	echo "Isso pode demorar alguns minutos."
	echo "Aguarde..."
	svn export https://github.com/DBAGlobal/Globalpoc/trunk/Softwares/11g/p6880880_112000_Linux-x86-64.zip
	mv p6880880_112000_Linux-x86-64.zip $ORACLE_HOME
}
# Diretórios de scripts Globalsys
function globalsys(){
	su - oracle
	mkdir -p /home/oracle/globalsys/gerais
	mkdir -p /home/oracle/globalsys/scripts
	exit
}

globalsys