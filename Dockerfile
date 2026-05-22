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

# Symlink bundled Claude CLI so it's available as 'claude-cli' globally
RUN ln -s "$(find / -name claude -path '*/claude_agent_sdk/_bundled/*' -type f 2>/dev/null | head -1)" /usr/local/bin/claude-cli

# Expose the port (default 8000)
EXPOSE 8000

# Run the app with Uvicorn (development mode with reload; switch to --no-reload for prod)
CMD ["poetry", "run", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]