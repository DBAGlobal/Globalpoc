Globalpoc
==================
Respositório de arquivos de configuração e instalação da Globalsys. Aplicável em novos servidores, criando toda a estrutura Oracle de acordo com as boas práticas.

###Gerais
Diretório que contém todos os arquivos SQL utilizados em consultas. Após instalação o diretório default será: ~~~ sh /home/oracle/globalsys/Gerais. ~~~

==================

####Instalação
Após efetuar o download do repositório no servidor alvo, entre no diretório, dê permissão de execução para o script e execute:
~~~ 
cd ~/Globalpoc
chmod +x install.sh
./install.sh
~~~