# Start from an ubuntu image.
FROM ubuntu:14.04

# Install system dependencies
RUN apt-get -y update
RUN apt-get -y install \
  build-essential \
  curl \
  git \
  libffi-dev \
  libmysqlclient-dev \
  libreadline6-dev \
  libsqlite3-dev \
  libssl-dev \
  libyaml-dev \
  zlib1g-dev

# Download ruby 2.2.2
WORKDIR /tmp/
RUN curl http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.gz | tar xz

# Install ruby 2.2.2
WORKDIR /tmp/ruby-2.2.2/
RUN ./configure --disable-install-rdoc
RUN make -j 4
RUN make -j 4 install
RUN gem install bundler
RUN bundle config --global jobs 8

# Add app code and set file permissions
WORKDIR /
ADD . /opt/nahiluhmot/tabular-backend
RUN useradd --create-home --user-group tabular
RUN chown -R tabular:tabular /opt/nahiluhmot/tabular-backend/

# Install ruby dependencies
WORKDIR /opt/nahiluhmot/tabular-backend/
USER tabular
RUN bundle install --deployment

# Default startup command
CMD bundle exec rake web
