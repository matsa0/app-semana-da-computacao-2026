
<h1 style="text-align:center;">˗ˏˋ  Aplicativo para a Semana da Computação do DECSI ˎˊ˗ </h1>

<div style="text-align:center;">
    <img src="./semana_da_computacao_logo.jpg" width="600px">
</div>

Como trabalho da disciplina de **Gerência  de Projetos de Software**, o projeto consiste no desenvolvimento de um aplicativo em Flutter
para a Semana da Computação do DECSI. O propósito desse aplicativo é melhorar a experiência dos paritcipantes e organizadores do evento centralizando informações e funcionalidades fundamentais para o bom funcionamento do evento. Além disso, produzir documentos e artefatos, aplicando os conceitos do Guia PMBOK e baseando-se em boas práticas de gerenciamento de projetos de software. Os documentos produzidos e atualizados são:

- Documento de escopo
- Gráfico de Gantt para gerenciamento de cronograma
- Planilha para gerenciamento de custos
- Documento de gerenciamento de riscos
- Documento de gerenciamento de qualidade



# 🛠️ Tecnologias 

`Flutter`
<br>
`Firebase`

# ⏳ Como rodar o projeto

Como IDE padrão de desenvolvimento, foi utilizado o **VSCode**, que tem um ótimo suporte para Flutter através da extensão [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) da Dart Code, que permite editar, refatorar, rodar e recarregar o aplicativo. Então, é muito recomendado que seja feita a adição dessa extensão ao projeto.

> ⚠️ Observação: a extensão do Flutter **não garante** a instalação global do Dart ou Flutter no sistema. Caso o VSCode não sugira a instalação do SDK, o projeto utiliza o **FVM** para
gerenciar e instalar a versão correta do Flutter.

> ⚠️ Observação: para desenvolvimento Android é necessário o **Android SDK**.
A forma recomendada é instalar o **Android Studio**, mesmo que a IDE utilizada seja o VS Code,
pois ele instala e configura automaticamente todos os componentes necessários.

## Instalação do FVM

Para melhor versionamento do Flutter, utilizamos o `FVM (Flutter Version Management)`, que além de evitar conflitos de versões e ambientes (Windows/Linux), permite que o projeto possa ter várias versões da tecnologia. Portanto, caso necessário, a troca de versão é muito facilitada.

### Linux

Para instalar a última versão do FVM **Linux**, basta digitar o seguinte no terminal:

```console
$ curl -fsSL https://fvm.app/install.sh | bash

# adicione à variável PATH (bash)
export PATH="$HOME/fvm/bin:$PATH"
```

### Windows

Para instalar a última versão do FVM no **Windows**, basta digitar o seguinte no PowerShell:

```console
> dart pub global activate fvm
``` 

Após instalar, feche o terminal e rode o seguinte comando para verificar se o FVM está corretamente instalado:

```console
$ fvm --version
```

### Instalação do Flutter via FVM

Garantindo que o fvm está corretamente instalado, instale a versão do Flutter definida no projeto com o comando:

```console
$ fvm install
```

Após isso, instale outras dependências do projeto com:

```console
$ fvm flutter pub get
```

Para finalizar, rode o projeto com:

```console
$ fvm flutter run
```

# 👥 Desenvolvedores

- Geovana S. de Oliveira
- Matheus S. Azevedo
- Mariana S. Vieira
- Talia F. Mendes
