# Use uma imagem base do Ubuntu 22.04
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instala dependências essenciais
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    git \
    unzip \
    wget \
    openjdk-17-jdk \
    libgtk-3-dev \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    && apt-get clean

# Wrapper para o 'tar' para evitar erros de permissão
RUN echo '#!/bin/sh' > /usr/local/bin/tar && \
    echo 'exec /bin/tar --no-same-owner "$@"' >> /usr/local/bin/tar && \
    chmod +x /usr/local/bin/tar

# 2. Instala o Flutter SDK
ENV FLUTTER_HOME /opt/flutter
ENV PATH "$FLUTTER_HOME/bin:$PATH"
# --- ALTERAÇÃO AQUI ---
# Trocamos a versão fixa pela 'stable' e adicionamos '--depth 1' para um clone mais rápido.
RUN git clone https://github.com/flutter/flutter.git --depth 1 -b stable $FLUTTER_HOME

# 3. Instala o Android SDK Command-line Tools
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV PATH "$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

# 4. Aceita as licenças do SDK e instala os pacotes necessários
RUN yes | sdkmanager --licenses > /dev/null && \
    sdkmanager "platforms;android-34" "build-tools;34.0.0" "platform-tools"

# 5. Configura o Flutter para usar o Android SDK e verifica a instalação
RUN flutter config --android-sdk ${ANDROID_SDK_ROOT} && \
    flutter doctor -v

# 6. Prepara o ambiente da aplicação
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .

# 7. O comando padrão será apenas um shell
CMD ["/bin/bash"]
