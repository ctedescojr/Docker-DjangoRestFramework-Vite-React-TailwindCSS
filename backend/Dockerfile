# syntax=docker/dockerfile:1
# Enable Docker BuildKit modern frontend syntax for advanced features like cache mounts.

# ==============================================================================
# Multi-Stage Dockerfile for Django with Astral uv (Production Best Practices)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. BUILDER STAGE
# ------------------------------------------------------------------------------
# Use the slim Python image to compile dependencies in an isolated build environment.
FROM python:3.14.1-slim AS builder

# Build environment variables:
# - PYTHONDONTWRITEBYTECODE: Prevents writing .pyc files to disk during build.
# - PYTHONUNBUFFERED: Ensures Python output is sent straight to terminal without buffering.
# - DEBIAN_FRONTEND: Suppresses interactive prompts during apt package installation.
# - UV_COMPILE_BYTECODE: Instructs uv to compile Python packages to bytecode for faster startup.
# - UV_LINK_MODE=copy: Ensures uv copies files into .venv instead of relying on hardlinks.
# - UV_PROJECT_ENVIRONMENT=/opt/venv: Creates virtual environment outside /app to avoid bind-mount collisions.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/venv

# Install operating system dependencies required to build and compile C extensions:
# - build-essential, python3-dev: gcc/make toolchain and Python development headers.
# - libpq-dev: PostgreSQL client development headers (needed to build psycopg).
# - git, curl: Utilities for downloading packages and tooling.
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    python3-dev \
    git \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy uv binaries directly from the official Astral uv image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set standard working directory inside the container
WORKDIR /app

# Copy dependency definition files first to leverage Docker layer caching.
# This layer is only rebuilt when pyproject.toml or uv.lock changes.
COPY pyproject.toml uv.lock ./

# Create isolated virtual environment in /opt/venv and sync dependencies from uv.lock.
# - --frozen: Ensures uv does not upgrade packages beyond what is locked in uv.lock.
# - --no-install-project: Installs third-party dependencies without installing the project itself.
RUN uv sync --frozen --no-install-project


# ------------------------------------------------------------------------------
# 2. RUNNER STAGE
# ------------------------------------------------------------------------------
# Lean final runtime image, free of heavy compilers and build tools.
FROM python:3.14.1-slim

# Runtime environment variables:
# - VIRTUAL_ENV: Points to the virtual environment location.
# - PATH: Adds the virtual environment (/opt/venv/bin) to the system PATH.
#   Allows commands like 'python', 'gunicorn', and 'celery' to run directly from /opt/venv.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

# Install only necessary runtime shared libraries:
# - gettext: Needed at runtime to compile Django translation catalogs (makemessages/compilemessages).
# - libpq5: Shared PostgreSQL client library for database connectivity.
# - libjpeg62-turbo, libpng16-16, libwebp7: Image processing support for Pillow.
# - tesseract-ocr, tesseract-ocr-por: OCR engine and Portuguese language pack for invoice processing.
# - curl: Used by container healthcheck.
# - gosu: Tool to step down from root privileges to appuser while preserving process signals.
RUN apt-get update && apt-get install -y \
    gettext \
    libpq5 \
    libjpeg62-turbo libpng16-16 libwebp7 \
    tesseract-ocr \
    tesseract-ocr-por \
    curl \
    gosu \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create non-root system user and group for security compliance
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy the complete virtual environment and uv binaries from the builder stage
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /bin/uv /usr/local/bin/uv
COPY --from=builder /bin/uvx /usr/local/bin/uvx

# Copy the application source code into the image (ensures self-contained container)
COPY . /app

# Set proper execution permissions and prepare directories with correct ownership
RUN chmod +x /app/entrypoint.sh && \
    if [ -f /app/scripts/init_project.sh ]; then chmod +x /app/scripts/init_project.sh; fi && \
    mkdir -p /app/media /app/staticfiles /app/logs && \
    chown -R appuser:appuser /opt/venv /app

# Expose HTTP port
EXPOSE 8000

# Healthcheck to verify the API is responding
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD [ "curl", "-f", "http://localhost:8000/api/health/" ]

# Entrypoint manages user UID/GID mapping, database connectivity, and migrations
ENTRYPOINT ["/app/entrypoint.sh"]

# Default command for production (overridden in docker-compose.yml for development)
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
