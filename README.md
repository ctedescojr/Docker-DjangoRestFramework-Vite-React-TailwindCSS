[English](#english) | [Português](#português)

---

<a name="english"></a>

# Dockerized Django, React, and Vite Boilerplate

This project provides a comprehensive, containerized boilerplate for building modern web applications. It integrates a Django Rest Framework backend with a Vite-powered React and TailwindCSS frontend, all managed by Docker and Docker Compose for seamless development and production workflows.

### Technologies Used

- **Containerization:** Docker, Docker Compose
- **Backend:** Django, Django Rest Framework, Gunicorn (with `uv` for package management)
- **Frontend:** React, Vite, TailwindCSS
- **Database:** PostgreSQL
- **Caching:** Redis
- **Async Tasks:** Celery (with Celery Beat for scheduling)
- **Web Server (Production):** Nginx

### Project Structure

```
.
├── backend/            # Django application source code
├── frontend/           # React + Vite application source code
├── mobile/             # Placeholder for a mobile application
├── .env.example        # Example environment variables
├── docker-compose.yml  # Docker Compose for development
└── docker-compose.prod.yml # Docker Compose for production
```

## Project Setup and Usage Guide

This guide provides instructions on how to set up and run this project in both development and production environments.

#### Prerequisites

- Docker
- Docker Compose

#### 1. Initial Environment Setup

Before running any commands, you need to set up your environment variables.

1.  **Create and configure the `.env` file:**
    Copy the example file. The setup will automatically use your current user and group ID to ensure correct file permissions.

    ```bash
    cp .env.example .env
    ```

2.  **Review the other variables:**
    Open the `.env` file and adjust any other values if necessary (e.g., database credentials, secret keys).

#### 2. First-Time Project Setup

The first time you run the development server, the backend and frontend projects will be automatically initialized.

1.  **Start the development environment:**

    ```bash
    docker-compose up --build
    ```

    - The first time this command runs, the `entrypoint.sh` script in the backend service automates the entire Django setup process. Here's what it does:
      - **Creates the Project Structure**: Initializes a Django project named `config`.
      - **Creates Core Applications**: Generates two essential apps:
        - `apps/core`: A general-purpose app for core functionalities like health checks or utility services.
        - `apps/users`: An app dedicated to user management, authentication, and profiles.
      - **Configures Settings**: Sets up a structured settings directory (`config/settings/`) with separate files for `base.py`, `development.py`, and `production.py` to manage different environments effectively.
      - **Sets Development Mode**: Automatically configures Django to use the `development.py` settings for the development environment.
      - **Database Readiness**: Creates a `wait_for_db` command to ensure the backend waits for the PostgreSQL database to be ready before starting.
    - On subsequent runs, the script detects that the project already exists and simply starts the server.

2.  **Automated Frontend Setup:**

    Similarly, the frontend's entrypoint script automates the entire setup if it detects an empty project. Here's a breakdown of what it does:

    - **Scaffolds the Project:** Creates a new Vite project using the React template.
    - **Installs Dependencies:** Runs `npm install` to get all the base React and Vite packages.
    - **Integrates TailwindCSS:** Installs `tailwindcss` and the official `@tailwindcss/vite plugin`.
    - **Configures File Paths:** Creates a `tailwind.config.js` file and configures it to scan your `index.html` and `src` directory for class names.
    - **Updates Vite Configuration:** Modifies `vite.config.js` to include the TailwindCSS plugin and sets server options (like `host` and `usePolling`) for optimal performance within Docker.
    - **Injects Base Styles:** Replaces the content of `src/index.css` with the required TailwindCSS `@import` directives.
    - **Provides a Sample App:** Overwrites `src/App.jsx` with a sample component styled with Tailwind classes, giving you immediate visual confirmation that the setup was successful.

#### 3. Running in Development Mode

To start all services (backend, frontend, database, etc.) for development after the initial setup, run:

```bash
docker-compose up
```

- **Backend API** will be available at `http://localhost:8000`
- **Frontend Dev Server** will be available at `http://localhost:5173` (with hot-reloading)

#### 4. Running in Production Mode

To build and run the production-ready containers, use the `docker-compose.prod.yml` file. This will build the static frontend files and serve them via Nginx.

```bash
docker-compose -f docker-compose.prod.yml up --build
```

- The **production application** will be available at `http://localhost` (port 80).

---

<a name="português"></a>

# Boilerplate Docker com Django, React e Vite

Este projeto fornece um boilerplate abrangente e containerizado para a construção de aplicações web modernas. Ele integra um backend Django Rest Framework com um frontend React e TailwindCSS alimentado por Vite, tudo gerenciado pelo Docker e Docker Compose para fluxos de trabalho de desenvolvimento e produção contínuos.

### Tecnologias Utilizadas

- **Containerização:** Docker, Docker Compose
- **Backend:** Django, Django Rest Framework, Gunicorn (com `uv` para gerenciamento de pacotes)
- **Frontend:** React, Vite, TailwindCSS
- **Banco de Dados:** PostgreSQL
- **Cache:** Redis
- **Tarefas Assíncronas:** Celery (com Celery Beat para agendamento)
- **Servidor Web (Produção):** Nginx

### Estrutura do Projeto

```
.
├── backend/            # Código-fonte da aplicação Django
├── frontend/           # Código-fonte da aplicação React + Vite
├── mobile/             # Espaço reservado para uma aplicação móvel
├── .env.example        # Exemplo de variáveis de ambiente
├── docker-compose.yml  # Docker Compose para desenvolvimento
└── docker-compose.prod.yml # Docker Compose para produção
```

## Guia de Configuração e Uso do Projeto

Este guia fornece instruções sobre como configurar e executar este projeto nos ambientes de desenvolvimento e produção.

#### Pré-requisitos

- Docker
- Docker Compose

#### 1. Configuração Inicial do Ambiente

Antes de executar qualquer comando, você precisa configurar suas variáveis de ambiente.

1.  **Crie e configure o arquivo `.env`:**
    Copie o arquivo de exemplo. A configuração usará automaticamente o ID do seu usuário e grupo para garantir as permissões corretas dos arquivos.

    ```bash
    cp .env.example .env
    ```

2.  **Revise as outras variáveis:**
    Abra o arquivo `.env` e ajuste quaisquer outros valores se necessário (ex: credenciais do banco de dados, chaves secretas).

#### 2. Configuração Inicial do Projeto

Na primeira vez que você executar o servidor de desenvolvimento, os projetos de backend e frontend serão inicializados automaticamente.

1.  **Inicie o ambiente de desenvolvimento:**

    ```bash
    docker-compose up --build
    ```

    - Na primeira vez que este comando for executado, o script `entrypoint.sh` no serviço de backend automatiza todo o processo de configuração do Django. Veja o que ele faz:
      - **Cria a Estrutura do Projeto**: Inicia um projeto Django chamado `config`.
      - **Cria as Aplicações Principais**: Gera duas aplicações essenciais:
        - `apps/core`: Uma aplicação de propósito geral para funcionalidades centrais, como verificações de saúde (health checks) ou serviços utilitários.
        - `apps/users`: Uma aplicação dedicada ao gerenciamento de usuários, autenticação e perfis.
      - **Configura as Definições (Settings)**: Cria um diretório de configurações estruturado (`config/settings/`) com arquivos separados para `base.py`, `development.py` e `production.py` para gerenciar diferentes ambientes de forma eficaz.
      - **Define o Modo de Desenvolvimento**: Configura automaticamente o Django para usar as definições de `development.py` no ambiente de desenvolvimento.
      - **Prontidão do Banco de Dados**: Cria um comando `wait_for_db` para garantir que o backend aguarde o banco de dados PostgreSQL estar pronto antes de iniciar.
    - Nas execuções seguintes, o script detecta que o projeto já existe e apenas inicia o servidor.

2.  **Configuração Automatizada do Frontend:**

    Da mesma forma, o script de entrada do frontend automatiza toda a configuração se detectar um projeto vazio. Aqui está um resumo do que ele faz:

    - **Cria a Estrutura do Projeto:** Cria um novo projeto Vite usando o template para React.
    - **Instala as Dependências:** Executa `npm install` para obter todos os pacotes base do React e Vite.
    - **Integra o TailwindCSS:** Instala o `tailwindcss` e o plugin oficial `@tailwindcss/vite`.
    - **Configura os Caminhos dos Arquivos:** Cria um arquivo `tailwind.config.js` e o configura para escanear seu arquivo `index.html` e o diretório `src` em busca de nomes de classes.
    - **Atualiza a Configuração do Vite:** Modifica o `vite.config.js` para incluir o plugin do TailwindCSS e define opções de servidor (como `host` e `usePolling`) para um desempenho otimizado dentro do Docker.
    - **Injeta os Estilos Base:** Substitui o conteúdo do arquivo `src/index.css` pelas diretivas `@import` necessárias do TailwindCSS.
    - **Fornece uma Aplicação de Exemplo:** Sobrescreve o `src/App.jsx` com um componente de exemplo estilizado com classes do Tailwind, fornecendo uma confirmação visual imediata de que a configuração foi bem-sucedida.

#### 3. Executando em Modo de Desenvolvimento

Para iniciar todos os serviços (backend, frontend, banco de dados, etc.) para desenvolvimento após a configuração inicial, execute:

```bash
docker-compose up
```

- A **API do Backend** estará disponível em `http://localhost:8000`
- O **Servidor de Desenvolvimento do Frontend** estará disponível em `http://localhost:5173` (com hot-reloading)

#### 4. Executando em Modo de Produção

Para construir e executar os contêineres prontos para produção, use o arquivo `docker-compose.prod.yml`. Este comando irá construir os arquivos estáticos do frontend e servi-los através do Nginx.

```bash
docker-compose -f docker-compose.prod.yml up --build
```

- A **aplicação em produção** estará disponível em `http://localhost` (porta 80).
