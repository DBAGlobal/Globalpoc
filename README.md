Globalpoc
==================
Respositório de arquivos de configuração e instalação da [Globalsys](http://www.globalsys.com.br). Aplicável em novos servidores, criando toda a estrutura Oracle de acordo com as boas práticas.

Para baixar a ferramenta `git` no servidor alvo, execute os seguintes comandos:
~~~
## Instalando dependências ##
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel -y
yum install gcc perl-ExtUtils-MakeMaker -y
yum remove git -y  #Apenas para servidores que já estão sendo utilizados, para remover qualquer versão que já possa estar instalada
~~~
~~~
## Baixando Git ##
cd /usr/src
wget https://www.kernel.org/pub/software/scm/git/git-2.2.2.tar.gz
tar xzf git-2.2.2.tar.gz
~~~
~~~
## Instalando ##
cd git-2.2.2
make prefix=/usr/local/git all
make prefix=/usr/local/git install
echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/bashrc
source /etc/bashrc
~~~
~~~
## Verificando instalação ##
git --version
~~~
==================

###Download do repositório
Após instalar a ferramente git no servidor alvo.
Faça o donwload do repositório executando o seguinte comando:
~~~
git clone https://github.com/DBAGlobal/Globalpoc
~~~

==================

###Gerais
Diretório que contém todos os arquivos SQL utilizados em consultas. Após instalação o diretório default será:
~~~
/home/oracle/globalsys/Gerais
~~~

==================

####Instalação
Após efetuar o download do repositório no servidor alvo, entre no diretório, dê permissão de execução para o script e execute:
~~~ 
cd ~/Globalpoc
chmod +x install.sh
# Exemplo: ./install.sh 6 11
./install.sh <versão so> <versao banco>
~~~

####Atualização
Para baixar atualizações do repositório execute:
~~~
su - root
cd ~/Globalpoc
chmod +x update.sh
./update.sh
~~~