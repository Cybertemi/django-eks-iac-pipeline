# =========================
# Stage 1: Builder
# =========================
FROM python:3.13.6-slim-bookworm AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install build dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y build-essential && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip & wheel safely
RUN pip install --upgrade pip wheel

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Prepare static files
ENV STATIC_ROOT=/app/staticfiles
RUN mkdir -p $STATIC_ROOT

# Use dummy env only for collectstatic if required
ENV DJANGO_SETTINGS_MODULE=primechoice.settings
RUN python manage.py collectstatic --noinput

# =========================
# Stage 2: Production
# =========================
FROM python:3.13.6-slim-bookworm

# Patch OS packages (fixes glibc CVEs)
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -r appuser

WORKDIR /app

# Copy Python runtime from builder
COPY --from=builder /usr/local/lib/python3.13/site-packages/ /usr/local/lib/python3.13/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/

# Copy application code
COPY --from=builder /app /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

USER appuser

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "primechoice.wsgi:application"]