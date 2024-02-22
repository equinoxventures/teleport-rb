FROM ruby:3.2 as teleport-ruby

# Default directory
ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

# Install teleport
RUN curl https://goteleport.com/static/install.sh | bash -s 15.0.1

#RUN chown -R user:user /opt/app
WORKDIR /app
RUN bundle install

# Run a shell
CMD ["/bin/sh"]