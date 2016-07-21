Globalpoc
==================
Respositório de arquivos de configuração e instalação da [Globalsys](http://www.globalsys.com.br). Aplicável em novos servidores, criando toda a estrutura Oracle de acordo com as boas práticas.

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