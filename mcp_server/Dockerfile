FROM ruby:3.3-alpine

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN apk add --no-cache build-base && \
    bundle config set --local without 'development test' && \
    bundle install

COPY . .

CMD ["ruby", "server.rb"]
