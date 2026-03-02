# =========================
# Stage 1: Builder
# =========================
FROM python:3.13-slim AS builder

# App directory
RUN mkdir /app
WORKDIR /app

# Python optimizations
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# System deps
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# -------------------------
# Build arguments (secrets)
# -------------------------
ARG DJANGO_SETTINGS_MODULE
ARG SECRET_KEY
ARG DATABASE_URL

# Set as environment variables for this stage
ENV DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
ENV SECRET_KEY=$SECRET_KEY
ENV DATABASE_URL=$DATABASE_URL

# Ensure static folder exists
ENV STATIC_ROOT=/app/staticfiles
RUN mkdir -p $STATIC_ROOT

# Collect static files
RUN python manage.py collectstatic --noinput

# =========================
# Stage 2: Production
# =========================
FROM python:3.13-slim

# Non-root user
RUN useradd -m -r appuser && \
    mkdir /app && \
    chown -R appuser /app

# Copy installed packages
COPY --from=builder /usr/local/lib/python3.13/site-packages/ /usr/local/lib/python3.13/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/

# Copy app code + collected static
COPY --from=builder /app /app

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

USER appuser

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "primechoice.wsgi:application"]