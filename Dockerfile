## Dockerfile for a haskell environment
FROM haskell:8.8.3

# Configure apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1

# Install haskell ide engine dependencies
RUN apt-get -y install libicu-dev libtinfo-dev libgmp-dev libncurses-dev

# Create symlink bind directory for build or haskell ide engine
RUN mkdir -p $HOME/.local/bin

# Install haskell ide engine
RUN stack upgrade

RUN stack install hlint

RUN stack install hoogle

RUN git clone https://github.com/haskell/haskell-ide-engine --recurse-submodules \
    && cd haskell-ide-engine \
    # Fix stack lts
    && sed -i "s|lts-14.27 # last lts GHC 8.6.5|lts-15.10 # GHC 8.8.3 |g" install/shake.yaml \
    && stack install.hs hie-8.8.3

RUN cd haskell-ide-engine \
    $$ stack install.hs data

RUN cd haskell-ide-engine \
    && stack --stack-yaml=stack-8.8.3.yaml exec hoogle generate

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog

# Set the default shell to bash rather than sh
ENV SHELL /bin/bash