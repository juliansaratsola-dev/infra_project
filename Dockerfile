# Dockerfile for vet_app
FROM python:3.9-slim

WORKDIR /app

# Copy application files
COPY vet_app/ /app/

# Install any dependencies if needed
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

# Create a non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Expose port if needed (optional for CLI app)
# EXPOSE 8000

# Default command - run the main application
CMD ["python", "main.py"]
