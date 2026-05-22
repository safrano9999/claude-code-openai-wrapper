FROM python:3.12-slim

# Install system deps (curl for Poetry installer)
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry globally
RUN curl -sSL https://install.python-poetry.org | python3 -

# Add Poetry to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Note: Claude Code CLI is bundled with claude-agent-sdk >= 0.1.8
# No separate Node.js/npm installation required

# Skip Claude Code onboarding wizard (no interactive TTY in container)
RUN echo '{"hasCompletedOnboarding":true}' > /root/.claude.json

# Copy the app code
COPY . /app

# Set working directory
WORKDIR /app

# Install Python dependencies with Poetry
RUN poetry install --no-root

# Expose the port (default 8000)
EXPOSE 8000

# Entrypoint: link bundled claude binary at runtime, then start server
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]