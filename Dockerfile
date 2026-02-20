 # Use Python 3.11 slim image as the base image
FROM python:3.11-slim

# Set environment variables
ENV ENVIRONMENT=production

#Set the working directory in the container
WORKDIR /app   

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
        build-essential \
        libpq-dev \
        gettext \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements/ requirements/
RUN pip install --no-cache-dir -r requirements/production.txt

# Copy project files to the container
COPY . .

# Create necessary directories for static and media files
RUN mkdir -p logs staticfiles media

# Set permissions for the directories
RUN chmod +x scripts/*.sh

# Collect static files
RUN python manage.py collectstatic --noinput --settings=churchms.settings.production

# Create a non-root user
RUN adduser --disabled-password --gecos '' appuser
RUN chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8000

# # Health check
# HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
#     CMD python manage.py check --database default || exit 1

# Run gunicorn server
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "churchms.wsgi:application"]


