# Dockerfile for analytics-service (Python)
FROM python:3.9-slim

WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Expose port
EXPOSE 8005

# Run with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8005", "app:app"]