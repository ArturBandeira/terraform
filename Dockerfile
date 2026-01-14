# Use Python 3.9 slim image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone https://github.com/ArturBandeira/RESTful-API.git

# Set working directory to the Flask app
WORKDIR /app/RESTful-API/RESTful/clientes_API

# Install Python dependencies
RUN pip3 install Flask flask-cors flask-httpauth werkzeug pymysql Flask-MySQL

# Copy configuration file
COPY config.py .

# Expose port 80
EXPOSE 80

# Run the application
CMD ["python3", "main.py", "--host=0.0.0.0", "--port=80"] 