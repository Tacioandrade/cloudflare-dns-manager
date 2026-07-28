FROM ghcr.io/cirruslabs/flutter:3.38.10

# Instala a plataforma exigida para builds destinados a Google Play.
RUN sdkmanager \
    "platforms;android-34" \
    "platforms;android-36" \
    "build-tools;35.0.0" \
    "build-tools;36.0.0" \
    "ndk;28.2.13676358" \
    "cmake;3.22.1"

# Define o diretório de trabalho
WORKDIR /app

# Copia os arquivos do projeto para o container
COPY . /app

# Baixa as dependências
# (Apenas será bem-sucedido após a criação do projeto Flutter)
RUN if [ -f pubspec.yaml ]; then flutter pub get; fi

# Expõe a porta para o servidor web de testes
EXPOSE 8080

# Comando padrão
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080", "--web-hostname", "0.0.0.0"]
