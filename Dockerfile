FROM ruby:2.6.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /myapp
WORKDIR /myapp
COPY evergarden.gemspec /myapp
COPY Gemfile /myapp
COPY Gemfile.lock /myapp
RUN gem update --system
RUN gem install bundler
RUN bundle install
COPY . /myapp
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "5000"]
