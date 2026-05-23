FROM ruby:4.0.4-alpine

LABEL io.modelcontextprotocol.server.name="io.github.igmarin/rails-agent-skills-mcp" \
      org.opencontainers.image.title="Rails Agent Skills MCP" \
      org.opencontainers.image.description="Curated library of AI agent skills for Ruby on Rails via MCP" \
      org.opencontainers.image.source="https://github.com/igmarin/rails-agent-skills" \
      org.opencontainers.image.licenses="MIT" \
      security.hardened="true" \
      security.no-new-privileges="true"

WORKDIR /app

# Create non-root user — WORKDIR must exist first (owned by root, intentional)
RUN addgroup -g 1000 mcp && adduser -u 1000 -G mcp -s /sbin/nologin -D mcp

# Copy only Gemfiles first to leverage Docker cache
COPY --chown=mcp:mcp mcp_server/Gemfile mcp_server/Gemfile.lock ./mcp_server/

# Install build deps, patch vulnerable default gems, bundle install, then clean up in one layer
RUN apk add --no-cache --virtual .build-deps build-base && \
    gem update json net-imap --no-document && \
    cd mcp_server && \
    bundle config set --local without 'development test' && \
    bundle install --no-cache && \
    apk del .build-deps && \
    rm -rf /tmp/* /var/tmp/*

# Copy the entire repository so skills, docs, and agents are available to the MCP server
COPY --chown=mcp:mcp . .

# Ensure the server uses the correct Gemfile regardless of the current directory
ENV BUNDLE_GEMFILE=/app/mcp_server/Gemfile \
    RUBYOPT="--enable-frozen-string-literal" \
    HOME=/home/mcp

# Switch to non-root user
USER mcp

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD pgrep -x ruby || exit 1

CMD ["bundle", "exec", "ruby", "mcp_server/server.rb"]
