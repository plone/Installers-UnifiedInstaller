=======
Windows
=======

**Desatualizado, precisa de tradutor brasileiro!**

Introdução
============

O Instalador Unificado do Plone pode ser usado para instalar o Plone no Windows 10 para fins de desenvolvimento, avaliação ou teste.
O Windows é uma escolha incomum para fins de produção (ao vivo, conectado à Internet); é possível fazer isso, mas requer experiência de integração do Windows que não é comum na comunidade Plone. Usar o Windows para desenvolvimento, avaliação, teste e treinamento, no entanto, não é problema.

Pré-requisitos
=============

Você precisará de conhecimentos adequados para abrir um prompt de comando, navegar no sistema de arquivos e executar programas através do prompt de comando.
Existem muitos tutoriais excelentes disponíveis, como `Windows Command Prompt in 15 Minutes <https://www.cs.princeton.edu/courses/archive/spr05/cos126/cmd-prompt.html>`_.

Exigências
============

- `Python 2.7.x x86-64 MSI Installer <https://www.python.org/downloads/windows/>`_ - escolha o "Windows x86-64 MSI installer" para o último Python 2.7.
- `Compilador Microsoft Visual C ++ para Python 2.7 <http://aka.ms/vcpython27>`_ - este é um subconjunto do MS VC ++ que fornece um kit de desenvolvimento completo para a versão Windows do Python 2.7.x.
- Tar, um utilitário de arquivamento compactado, para Windows. Esta é uma parte padrão do Windows desde a compilação 17063. Você pode verificar sua existência executando ``tar`` em um prompt de comando.
- Acesso à internet. Diferentemente da instalação Linux / Unix, a instalação do Windows precisa de acesso à Internet para instalar pacotes adicionais do PyPI Package Index (PyPI).

Verifique primeiro o tar. Se não estiver disponível, atualize sua cópia do Windows.
Em seguida, instale o Python, usando as instruções abaixo para garantir a escolha das opções corretas.
Por fim, instale o MSVC ++ Compiler for Python 2.7. Não há opções nesta instalação.

Instalando o Python
-----------------

- Escolha *Instalar para todos os usuários* ou *Instalar apenas para mim*.
- Na página "Personalizar Python 2.7.x (64 bits)" do instalador, role para baixo e clique na opção ``Adicionar python.exe ao caminho``.

Após a instalação, verifique se ``python.exe`` está no seu PATH.

Para testar se está no seu PATH, digite "python" e pressione Return; se você vir uma mensagem
``'python' não é reconhecido como um comando interno ou externo, programa operável ou arquivo em lote``
então ele não está no seu PATH e talvez você precise reiniciar o Windows.

Você pode adicioná-lo ao seu PATH manualmente com o comando ``PATH = $ PATH; c:\Python27``.


Faça o download do instalador unificado do Plone
====================================

Faça o download do instalador unificado do Plone em https://plone.org/download.
Acompanhe o local do download.

Instalando o Plone
================

Descompactando o instalador
-----------------------

Abra o prompt de comando do Windows. Mude o diretório atual para o local do download e use ``tar`` para descompactar o download.

.. code-block:: bat

    cd Download
    tar xf Plone-5.1.x-UnifiedInstaller.tgz

Substitua o **número da sua versão**, conforme necessário.

Executando o instalador
---------------------

Altere seu diretório atual para o diretório do arquivo descompactado e execute a rotina em lote de instalação do Windows:


.. code-block:: bat

    cd Plone-5.1.x-UnifiedInstaller
    windows_install.bat standalone --password=admin

Opções
.......

Execute ``windows-install.bat`` com o argumento "--help" para obter uma lista de opções::

    windows_install.bat --help
    usage: windows_install.py [-h] [--password PASSWORD] [--target TARGET]
                              [--instance INSTANCE] [--clients CLIENTS]
                              {zeo,standalone}

    Plone instance creation utility

    positional arguments:
      {zeo,standalone}     Instance type to create.

    optional arguments:
      -h, --help           show this help message and exit
      --password PASSWORD  Instance password; If not specified, a random password
                           will be generated.
      --target TARGET      Use to specify top-level path for installs. Plone
                           instances will be built inside this directory. Default
                           is \Users\steve\Plone.
      --instance INSTANCE  Use to specify the name of the operating instance to be
                           created. This will be created inside the target
                           directory. Default is "zinstance" for standalone,
                           "zeocluster" for ZEO.
      --clients CLIENTS    Use with the "zeo" install method to specify the number
                           of Zope clients you wish to create. Default is 2.


Resultados
-------

Espere que o instalador leve um tempo considerável para ser executado, com poucas mensagens após o início da compilação.
No final da instalação, espere uma mensagem como::

 ######################  Installation Complete  ######################

    Plone successfully installed at \Users\steve\Plone\zinstance
    See \Users\steve\Plone\zinstance\README.html
    for startup instructions.

    Use the account information below to log into the Zope Management Interface
    The account has full 'Manager' privileges.

      Username: admin
      Password: admin

    This account is created when the object database is initialized. If you change
    the password later (which you should!), you'll need to use the new password.

    Use this account only to create Plone sites and initial users. Do not use it
    for routine login or maintenance.

Se vir algo diferente, procure mensagens de erro.
Pode ser necessário ler o log de instalação no disco.

Uma vez instalado, espere que o Plone (e o buildout, se você estiver desenvolvendo) funcione como geralmente documentado.
Obviamente, você precisará usar nomes de caminho do Windows (substitua "\" por "/") em vez de formulários Unix.
