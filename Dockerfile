FROM centos:7

ENV ANYENV_ROOT=/usr/local/bin/anyenv
ENV RBENV_ROOT=$ANYENV_ROOT/envs/rbenv
ENV PLENV_ROOT=$ANYENV_ROOT/envs/plenv
ENV PHPENV_ROOT=$ANYENV_ROOT/envs/phpenv
ARG RUBY_VERSIONS="2.7 3.0"
ARG PERL_VERSIONS="5.32"
ARG PHP_VERSIONS="5 7 8"

RUN yum install -y epel-release \
    && yum install -y git curl gcc gcc-c++ make cmake3 patch autoconf \
    bzip2 libxml2 libxml2-devel libcurl libcurl-devel libpng libpng-devel \
    libmcrypt libmcrypt-devel \
    libtidy libtidy-devel libxslt libxslt-devel openssl-devel \
    bison libjpeg-turbo-devel readline-devel bzip2-devel sqlite-devel \
    libicu-devel oniguruma-devel libzip-devel postgresql-devel mysql-devel \
    && yum clean all

RUN curl https://libzip.org/download/libzip-1.7.3.tar.gz -o /libzip-1.7.3.tar.gz \
    && tar xzvf /libzip-1.7.3.tar.gz \
    && cd /libzip-1.7.3 \
    && cmake3 -DCMAKE_INSTALL_PREFIX=/usr/local/libzip \
    && make \
    && make install

ENV PKG_CONFIG_PATH $PKG_CONFIG_PATH:/usr/local/libzip/lib64/pkgconfig

RUN git clone https://github.com/anyenv/anyenv ${ANYENV_ROOT}

ENV PATH $ANYENV_ROOT/bin:$RBENV_ROOT/bin:$RBENV_ROOT/shims:$RBENV_ROOT/plugins/ruby-build/bin:$PLENV_ROOT/bin:$PLENV_ROOT/shims:$PLENV_ROOT/plugins/perl-build/bin:$PHPENV_ROOT/bin:$PHPENV_ROOT/shims:$PATH

RUN echo 'eval "$(anyenv init -)"' >> /etc/profile && source /etc/profile \
    && anyenv install --force-init \
    && anyenv install rbenv -f \
    && anyenv install plenv -f \
    && anyenv install phpenv -f

# Re-install phpenv using phpenv-installer
RUN curl -L https://raw.githubusercontent.com/phpenv/phpenv-installer/master/bin/phpenv-installer | bash

RUN echo '--with-pgsql' >> $PHPENV_ROOT/plugins/php-build/share/php-build/default_configure_options \
    && echo '--with-pdo-pgsql' >> $PHPENV_ROOT/plugins/php-build/share/php-build/default_configure_options

RUN if [ "$RUBY_VERSIONS" != "" ]; then for i in $RUBY_VERSIONS; do rbenv install $(rbenv install --list-all | grep ^$i | tail -1); done; fi

RUN if [ "$PERL_VERSIONS" != "" ]; then for i in $PERL_VERSIONS; do plenv install $(plenv install --list | grep "^ *$i" | head -1); done; fi

RUN if [ "$PHP_VERSIONS" != "" ]; then for i in $PHP_VERSIONS; do phpenv install $(phpenv install --list | grep "^ *$i" | grep -v snapshot | tail -1); done; fi

WORKDIR /

RUN rm -f /libzip-1.7.3.tar.gz \
    && rm -rf /libzip-1.7.3 \
    && rm -rf /tmp/*

COPY ./scripts/anyenv-init.sh /usr/bin/anyenv-init

RUN chmod +x /usr/bin/anyenv-init

COPY ./scripts/my.sh /usr/bin/my.sh

RUN chmod +x /usr/bin/my.sh

CMD ["/usr/bin/my.sh"]
