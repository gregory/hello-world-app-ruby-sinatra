FROM ruby:2.0.0-p576

RUN apt-get update &&\
    apt-get install -y -q sqlite3 libsqlite3-dev libpq-dev postgresql-server-dev-9.4 &&\
    rm -rf /var/lib/apt/lists/*

ENV USE_ENV true
ENV WORKDIR /opt/services/hello-world-ruby
ENV BUNDLE_PATH /usr/local/bundle
ENV GEM_HOME $BUNDLE_PATH
ENV HOME $WORKDIR
ENV BUNDLE_APP_CONFIG $GEM_HOME

RUN groupadd app &&\
    useradd -g app -d $WORKDIR -s /sbin/nologin -c 'Docker image user for the app' app &&\
    mkdir -p $WORKDIR $BUNDLE_PATH

RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc \
    && gem install bundler foreman --no-document

WORKDIR /opt/services/hello-world-ruby

COPY Gemfile* /opt/services/hello-world-ruby/

RUN bundle install --without debug --path $BUNDLE_PATH

ADD . /opt/services/hello-world-ruby

RUN chown -R app:app $WORKDIR $BUNDLE_PATH

USER app

CMD foreman start

