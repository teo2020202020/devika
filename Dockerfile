# Use an official Python runtime as a parent image
FROM python:3.10-slim as python_base

# Set the working directory
WORKDIR /app

# Install system dependencies for Playwright and Node.js
RUN apt-get update && \
    apt-get install -y curl ca-certificates libnss3 libatk-bridge2.0-0 libx11-xcb1 \
    libatk1.0-0 libgdk-pixbuf2.0-0 libnspr4 libxcomposite1 libxdamage1 libxrandr2 \
    libgbm1 libasound2 libpangocairo-1.0-0 libatk-1.0-0 libcups2 libdbus-1-3 \
    fonts-liberation libappindicator3-1 libgdk-pixbuf2.0-0 libnspr4 libx11-xcb1 \
    wget unzip && \
    rm -rf /var/lib/apt/lists/*

# Install uv - Python package manager
RUN pip install uv

# Clone the Devika repository and install backend dependencies
RUN git clone https://github.com/stitionai/devika.git /app
WORKDIR /app
RUN uv venv && \
    source .venv/bin/activate && \
    uv pip install -r requirements.txt

# Install Playwright for browsing capabilities
RUN playwright install --with-deps

# Install Node.js, Bun, and frontend dependencies
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"
RUN cd /app/ui && bun install

# Expose port for the backend and frontend
EXPOSE 3001

# Start the Devika server and frontend UI
CMD ["bash", "-c", "python devika.py & cd ui && bun run start"]
