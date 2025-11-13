# --- Builder ---
FROM python:3.14-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    python3-dev \
    postgresql-client \
    curl \
    libjpeg-dev libpng-dev libwebp-dev \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create virtual environment
WORKDIR /opt
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements and install dependencies
COPY requirements/ /tmp/requirements/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /tmp/requirements/development.txt

# Set the working directory
WORKDIR /app

# --- Runner ---
FROM python:3.14-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies and gosu
RUN apt-get update && apt-get install -y \
    libpq5 \
    libjpeg62-turbo libpng16-16 libwebp7 \
    curl \
    gosu \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create user and working directory
WORKDIR /app
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy entrypoint script and requirements
COPY entrypoint.sh /app/
COPY requirements/ /app/requirements/

# Create directories and set permissions
RUN chmod +x /app/entrypoint.sh && \
    mkdir -p /app/media /app/staticfiles /app/logs && \
    chown -R appuser:appuser /app

# The container will be started as root and the entrypoint will use gosu to step down to the appuser.
# USER appuser

# Expose port
EXPOSE 8000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/api/health/ || exit 1

# Entrypoint and default command
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
