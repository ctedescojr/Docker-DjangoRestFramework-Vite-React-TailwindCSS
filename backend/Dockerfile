# --- Best Practices Dockerfile for Django with uv ---

# --- Builder Stage ---
# Use a specific version of Python for reproducibility.
# 'slim' is a good balance between size and having necessary tools.
FROM python:3.14.1-slim AS builder

# Set environment variables to prevent generating .pyc files and to ensure output is unbuffered.
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Group apt-get commands to reduce layers and clean up cache to keep the image small.
RUN apt-get update && apt-get install -y \
    # Build dependencies for Python packages
    build-essential \
    libpq-dev \
    python3-dev \
    # Client for connecting to PostgreSQL
    postgresql-client \
    # Needed to download uv
    curl \
    # Dependencies for Pillow (image processing)
    libjpeg-dev libpng-dev libwebp-dev \
    # Needed for some version control-based package installs
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install uv, the modern Python package manager, directly to a system-wide location.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set the working directory.
WORKDIR /app

# Copy only the requirements files first to leverage Docker's layer caching.
# The layer will only be rebuilt if the requirements files change.
COPY pyproject.toml uv.lock ./


# Install Python dependencies into the system's site-packages.
# We use --system because the container itself provides the isolation, making a venv redundant.
RUN uv pip install --system --no-cache .


# --- Runner Stage ---
# Start from the same slim base image for the final container.
FROM python:3.14.1-slim

# Set environment variables.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PATH="/usr/local/bin:$PATH"

# Install only the necessary runtime dependencies to keep the final image lean.
RUN apt-get update && apt-get install -y \
    # PostgreSQL client library
    libpq5 \
    # Runtime libraries for Pillow
    libjpeg62-turbo libpng16-16 libwebp7 \
    # Needed for the healthcheck
    curl \
    # Used in the entrypoint to drop root privileges
    gosu \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user and group for security best practices.
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set the working directory.
WORKDIR /app

# Copy the installed uv binary from the builder stage to make it available at runtime.
# The source path is where the default uv installer places the binary.
# The destination path is a standard location for executables in the final image.
COPY --from=builder /bin/uv /usr/local/bin/uv
COPY --from=builder /bin/uvx /usr/local/bin/uvx

# Copy the installed Python packages and their executables (like gunicorn, django-admin)
# from the builder stage. This is the key to making the multi-stage build work.
COPY --from=builder /usr/local/lib/python3.14/site-packages /usr/local/lib/python3.14/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy the entrypoint script and requirements directory.
COPY entrypoint.sh /app/
COPY pyproject.toml uv.lock ./

# Create necessary directories and set correct permissions for the non-root user.
RUN chmod +x /app/entrypoint.sh && \
    mkdir -p /app/media /app/staticfiles /app/logs && \
    chown -R appuser:appuser /app

# Expose the port the application will run on.
EXPOSE 8000

# Healthcheck to verify the application is running and healthy.
# Using array form is a best practice.
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD [ "curl", "-f", "http://localhost:8000/api/health/" ]

# The entrypoint script handles database checks, migrations, and user privilege dropping.
ENTRYPOINT ["/app/entrypoint.sh"]

# The default command to run the application.
# Using 'uv run' ensures the command is executed in the correct environment context.
CMD ["uv", "run", "gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
