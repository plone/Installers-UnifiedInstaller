===============================
Plone 5.2: Instalador Unificado
===============================

Idioma: `Inglês <README.rst>`_ | `Português(Brasil) <README-pt-br.rst>`_

O instalador unificado do Plone instala o Plone
e suas dependências da fonte na maioria das plataformas semelhantes ao Unix e Windows 10.

O kit inclui o Plone e o Zope e fará o download de componentes como o Python, se necessário.

O Python é instalado de uma maneira que não muda nem interfere no Python do seu sistema.

**Importante: Faça backup do seu site Plone existente antes de executar o instalador
ou executando o buildout para atualizar.**

Características
========

- Verifica as dependências necessárias
- Escolha entre o zeo e a instalação autônoma
- Escolha entre instalação do usuário e raiz
- Crie usuário e grupo do sistema para executar o plone

Para obter uma lista completa de recursos, consulte a `documentação <http://docs.plone.org/manage/installing/installation.html#installing-plone-using-the-unified-unix-installer>`_.

Instalação
============

Usuários do Windows: consulte as `Instruções do Windows <docs/pt-br/windows.rst>`_.

Faça o download do instalador:

.. code-block:: shell

  wget --no-check-certificate https://launchpad.net/plone/5.2/5.2.12/+download/Plone-5.2.12-UnifiedInstaller-1.0.tgz

Extraia o arquivo baixado:


.. code-block:: shell

  tar -xf Plone-5.2.12-UnifiedInstaller-1.0.tgz

Vá para a pasta que contém o script do instalador:

.. code-block:: shell

  cd Plone-5.2.12-UnifiedInstaller-1.0

Execute o script:

.. code-block:: shell

   ./install.sh $OPTION

Se você executar o instalador sem argumentos de opção, ele fará uma série de perguntas sobre opções básicas.

O instalador procurará no caminho do sistema os executáveis Python 2.7 e Python 3.x candidatos à criação da sua instalação.
Se você deseja especificar um executável Python específico, use:

.. code-block:: shell

   ./install.sh --with-python/usr/bin/python3 [other options]

Substituindo o caminho para o seu Python 2.7 ou 3.5+.

Para obter uma lista completa de opções, muitas das quais não estão disponíveis nas perguntas da caixa de diálogo, use:

.. code-block:: shell

   ./install.sh --help


**Nota:**

   Para certas opções de instalação de produção, você precisará executar o instalador com `` sudo`` ou como root.

   Geralmente, isso não é necessário ao criar sistemas de desenvolvimento ou avaliação.

Documentação
=============

A documentação completa para usuários finais pode ser encontrada no diretório */docs* deste repositório.

Também está disponível como parte de nossa `documentação <http://docs.plone.org/manage/installing/installation.html#installing-plone-using-the-unified-unix-installer>`_.

Contribuir
==========

- Rastreador de problemas: https://github.com/plone//Installers-UnifiedInstaller/issues
- Código-fonte: https://github.com/plone//Installers-UnifiedInstaller
- Documentação: http://docs.plone.org/manage/installing/installation.html/unified-unix-installer


Apoio, suporte
=======

Se você estiver tendo problemas, informe-nos.

Temos nosso espaço comunitário em: https://community.plone.org/c/development/installer


Licença
=======

O projeto está licenciado sob a GPLv2.
