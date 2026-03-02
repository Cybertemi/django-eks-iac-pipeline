# =========================
# Stage 1 — Build Wheels
# =========================
FROM python:3.13.6-slim-bookworm AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system build deps
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y build-essential && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip & wheel explicitly (fixes CVE)
RUN pip install --upgrade pip wheel==0.46.2

# Copy requirements
COPY requirements.txt .

# Build wheels only (clean dependency artifacts)
RUN pip wheel --no-cache-dir --no-deps -r requirements.txt -w /wheels


# =========================
# Stage 2 — Production
# =========================
FROM python:3.13.6-slim-bookworm

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Patch OS packages (fixes glibc if patch exists)
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# Upgrade pip & wheel again (ensures correct version in final image)
RUN pip install --upgrade pip wheel==0.46.2

# Copy built wheels from builder
COPY --from=builder /wheels /wheels

# Install runtime dependencies only
RUN pip install --no-cache-dir /wheels/*

# Copy application code
COPY . .

# Create non-root user
RUN useradd -m -r appuser && chown -R appuser /app
USER appuser

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "primechoice.wsgi:application"]