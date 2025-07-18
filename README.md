# Flutter Podman DevEnv 🚀

Um ambiente de desenvolvimento Flutter completo e otimizado, rodando em um contêiner Podman. Desenvolva, compile e depure seus apps para Android em um ambiente isolado, limpo e performático, sem a necessidade de instalar o Flutter SDK ou o Android SDK diretamente na sua máquina.

## ✨ Benefícios Principais

* **Ambiente Limpo e Isolado:** Mantenha sua máquina host livre de dependências e configurações complexas do Java, Android SDK e Flutter. Tudo que você precisa está dentro do contêiner.
* **Consistência entre Desenvolvedores:** Garanta que toda a equipe utilize exatamente a mesma versão de SDKs e dependências, eliminando o clássico "mas na minha máquina funciona".
* **Performance:** A execução em contêineres modernos, especialmente em discos rápidos (SSDs NVMe), pode proporcionar uma sensação de performance superior, graças ao acesso otimizado ao sistema de arquivos.
* **Portabilidade:** Leve seu ambiente de desenvolvimento para qualquer máquina que tenha o Podman (ou Docker) instalado.
* **Depuração em Dispositivo Físico:** Conecte seu smartphone via USB e realize a depuração (debugging) do seu app diretamente do contêiner, com total suporte ao ADB.
* **Setup Simplificado:** Com apenas dois ou três comandos, seu ambiente está pronto para uso.

## 📋 Pré-requisitos

* [**Podman**](https://podman.io/getting-started/installation) instalado na sua máquina. (A maioria dos comandos também é compatível com Docker).
* Um **dispositivo Android físico** com o modo de desenvolvedor e a depuração USB ativados.
* O servidor **ADB (Android Debug Bridge)** rodando na sua máquina host.

## 🚀 Começando

Siga os passos abaixo para construir a imagem e iniciar seu ambiente de desenvolvimento.

### 1. Clone este Repositório

```bash
git clone [https://github.com/SEU-USUARIO/SEU-REPOSITORIO.git](https://github.com/SEU-USUARIO/SEU-REPOSITORIO.git)
cd SEU-REPOSITORIO
```

### 2. Construa a Imagem do Contêiner

Execute o comando abaixo para construir a imagem. Isso pode levar alguns minutos na primeira vez.

```bash
podman build -t flutter-dev .
```
* `-t flutter-dev`: Define o nome (`tag`) da imagem como `flutter-dev` para facilitar a referência.

### 3. Inicie o Contêiner de Desenvolvimento

**Primeiro, certifique-se de que seu celular esteja conectado via USB e que o servidor ADB esteja rodando na sua máquina host.** Você pode iniciá-lo com:
```bash
adb start-server
```

Agora, **navegue até o diretório do seu projeto Flutter** e execute o seguinte comando para iniciar o contêiner:

```bash
podman run --rm -it \
  --network=host \
  -v .:/app:Z \
  -v ~/.android:/root/.android:Z \
  -v /dev/bus/usb:/dev/bus/usb \
  flutter-dev
```

**Entendendo os parâmetros:**
* `--rm -it`: Inicia o contêiner em modo interativo e o remove automaticamente ao sair.
* `--network=host`: Permite que o contêiner se comunique com a rede da sua máquina, essencial para o ADB e o Hot Reload do Flutter.
* `-v .:/app:Z`: Mapeia o diretório atual (`.`) — onde seu projeto Flutter está — para o diretório `/app` dentro do contêiner.
* `-v ~/.android:/root/.android:Z`: **(O pulo do gato!)** Mapeia as configurações do ADB da sua máquina para o contêiner. Isso evita que você precise autorizar a depuração USB no seu celular repetidamente.
* `-v /dev/bus/usb:/dev/bus/usb`: Permite que o contêiner acesse os dispositivos USB, possibilitando que o ADB encontre seu celular.
* `:Z`: É um marcador para o SELinux (comum em sistemas como o Fedora), que ajusta as permissões do volume para que o contêiner possa ler e escrever nos arquivos.
* `flutter-dev`: O nome da imagem que você construiu no passo anterior.

Você agora estará dentro do shell do contêiner, no diretório `/app`, com seu código-fonte já disponível e pronto para trabalhar!

## 🛠️ Como Usar

Uma vez dentro do contêiner, você pode usar os comandos do Flutter normalmente.

### Verificando a Conexão com o Dispositivo

Para garantir que o contêiner está enxergando seu celular, execute:

```bash
flutter devices
```

A saída deve listar seu dispositivo conectado.

### Comandos Comuns do Flutter

* **Instalar dependências:**
    ```bash
    flutter pub get
    ```

* **Executar o app em modo de depuração:**
    ```bash
    flutter run
    ```
    O app será compilado, instalado no seu celular e o Hot Reload estará ativado!

* **Construir um APK:**
    ```bash
    flutter build apk --release
    ```

* **Executar testes:**
    ```bash
    flutter test
    ```

## 🧠 Entendendo o `Containerfile`

Este `Containerfile` foi otimizado para performance e praticidade:

1.  **Dependências Essenciais:** Instala apenas o necessário sobre uma base `ubuntu:22.04`.
2.  **Wrapper do `tar`:** A linha `exec /bin/tar --no-same-owner "$@"` é um truque para evitar problemas de permissão ao extrair arquivos como usuário root dentro do contêiner, um problema comum ao se trabalhar com os SDKs do Flutter/Android.
3.  **Clone Rápido do Flutter:** Usa `git clone --depth 1 -b stable` para baixar apenas a versão mais recente do canal estável, tornando a construção da imagem muito mais rápida.
4.  **Cache de Dependências:** A estrutura `COPY pubspec.*`, `RUN flutter pub get`, e depois `COPY . .` é uma prática padrão que acelera reconstruções da imagem. O passo `flutter pub get` só será executado novamente se o seu arquivo `pubspec.yaml` ou `pubspec.lock` for alterado.

## 🤝 Contribuições

Sinta-se à vontade para abrir uma *issue* ou enviar um *pull request* para melhorar este ambiente de desenvolvimento.

---
Feito com ❤️ por [Seu Nome ou Nickname]
