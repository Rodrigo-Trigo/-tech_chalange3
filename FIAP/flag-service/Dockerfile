# Dockerfile for flag-service (Python)
FROM python:3.9-slim

WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Expose port
EXPOSE 8002

# Run with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8002", "app:app"]