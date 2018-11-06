FROM ubuntu:18.04

# Better terminal support
ENV TERM screen-256color
ENV DEBIAN_FRONTEND noninteractive


# Update and install
RUN apt-get update && apt-get install -y \
      htop \
      bash \
      curl \
      wget \
      git \
      software-properties-common \
      python-dev \
      python-pip \
      python3-dev \
      python3-pip \
      ctags \
      shellcheck \
      netcat \
      ranger \ 
      ack-grep \
      sqlite3 \
      unzip \
      # For python crypto libraries
      libssl-dev \
      libffi-dev \
      locales \
      cmake \
      gcc \
      sudo \
      g++

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get install -y nodejs
RUN npm install -g eslint neovim

# Generally a good idea to have these, extensions sometimes need them
# RUN locale-gen en_US.UTF-8
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US:en
# ENV LC_ALL en_US.UTF-8<Paste>

# Install Neovim
RUN add-apt-repository ppa:neovim-ppa/stable
RUN apt-get update && apt-get install -y \
		neovim

# Install Ledger
# RUN add-apt-repository ppa:mbudde/ledger
# RUN apt-get update && apt-get install -y \
# 		ledger

# Install Terraform for linting
RUN wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip && \
    unzip terraform_0.11.8_linux_amd64.zip && \
		mv terraform /usr/bin

# Install python linting and neovim plugin
RUN pip3 install neovim jedi flake8 flake8-docstrings flake8-isort flake8-quotes
RUN pip3 install pep8-naming pep257 isort mypy ansible-lint flake8-bugbear
RUN pip3 install flake8-commas flake8-comprehensions
RUN pip3 install --upgrade neovim

ADD gitconfig /etc/gitconfig
ADD bashrc /root/.bashrc
ADD bashrc.aliases /root/.bashrc.aliases

WORKDIR /root/app

RUN infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > /tmp/$TERM.ti
RUN tic /tmp/$TERM.ti

# Command for the image
CMD ["/bin/bash"]

# Add nvim config. Put this last since it changes often
ADD nvim-config.d /root/.config/nvim
ADD vim-config.d /root/.vim

# Install neovim plugins
RUN nvim -i NONE -c PlugInstall -c quitall > /dev/null 2>&1

# Add flake8 config, don't trigger a long build process
ADD flake8 /root/.flake8
ADD isort.cfg /root/.isort.cfg
ADD rc.conf /root/.config/ranger/rc.conf
