# ---------------------------
# Base e dependências do sistema
# ---------------------------

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1

ARG USERNAME
ARG USER_UID
ARG USER_GID

# Instala dependências
RUN apt-get update && apt-get install -y \
    curl wget git zsh sudo gnupg2 lsb-release ca-certificates \
    build-essential libssl-dev libreadline-dev zlib1g-dev \
    python3 python3-pip python3-venv \
    neovim tmux fzf ripgrep unzip \
    postgresql-client openssh-client make \
    direnv nodejs npm catimg \
    software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------------------------
# Criação do usuário
# ---------------------------

# Cria o usuário
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/zsh \
  && usermod -aG sudo $USERNAME \
  && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copia .zshrc
COPY .zshrc /home/$USERNAME/.zshrc
RUN chown $USERNAME:$USERNAME /home/$USERNAME/.zshrc

# Troca para o usuário final
USER $USERNAME
WORKDIR /home/$USERNAME

# ---------------------------
# Instalação de ferramentas
# ---------------------------

# Instalar oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Instalar pyenv, Rust e outras ferramentas
RUN curl https://pyenv.run | bash \
  && curl https://sh.rustup.rs -sSf | sh -s -- -y

# Instala o NVM e o Node.js LTS
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
  export NVM_DIR="$HOME/.nvm" && \
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
  nvm install --lts && npm install -g yarn typescript

# Instala o Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Instala pyright
RUN pip install --no-cache-dir pyright

# Instala aws-cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  sudo ./aws/install

# ---------------------------
# Carregando Ambiente das Ferramentas
# ---------------------------

# Zshrc
RUN echo '# Zshrc Default' >> /home/$USERNAME/.zshrc && \
    echo 'export ZSH="$HOME/.oh-my-zsh"' >> /home/$USERNAME/.zshrc && \
    echo 'export ZSH_THEME="spaceship"' >> /home/$USERNAME/.zshrc && \
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting z)' >> /home/$USERNAME/.zshrc && \
    echo 'export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"' >> /home/$USERNAME/.zshrc && \
    echo 'export MANPATH="/usr/local/man:$MANPATH"' >> /home/$USERNAME/.zshrc && \
    echo 'alias zshconfig="mate ~/.zshrc"' >> /home/$USERNAME/.zshrc && \
    echo 'alias ohmyzsh="mate ~/.oh-my-zsh"' >> /home/$USERNAME/.zshrc && \
    echo 'source $ZSH/oh-my-zsh.sh' >> /home/$USERNAME/.zshrc

ENV ZSH_CUSTOM=/home/$USERNAME/.oh-my-zsh/custom

# Pyenv
RUN echo '# Pyenv' >> /home/$USERNAME/.zshrc && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /home/$USERNAME/.zshrc && \
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/$USERNAME/.zshrc && \
    echo 'eval "$(pyenv init -)"' >> /home/$USERNAME/.zshrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> /home/$USERNAME/.zshrc

# NVM
RUN echo '# Nvm' >> /home/$USERNAME/.zshrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> /home/$USERNAME/.zshrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/$USERNAME/.zshrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /home/$USERNAME/.zshrc

# Nvim
RUN echo '# Nvim' >> /home/$USERNAME/.zshrc && \
    echo 'export PATH="$PATH:/opt/nvim/bin"' >> /home/$USERNAME/.zshrc

# Direnv
RUN echo '# Direnv' >> /home/$USERNAME/.zshrc && \
    echo 'eval "$(direnv hook zsh)"' >> /home/$USERNAME/.zshrc

# Rust
RUN echo '# Rust' >> /home/$USERNAME/.zshrc && \
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> /home/$USERNAME/.zshrc

# Yarn
RUN echo '# Yarn' >> /home/$USERNAME/.zshrc && \
    echo 'export PATH="$HOME/.yarn/bin:$PATH"' >> /home/$USERNAME/.zshrc


# ---------------------------
# Setup do Neovim
# ---------------------------

USER root
RUN add-apt-repository ppa:neovim-ppa/unstable && \
  apt-get update && \
  apt-get install -y neovim && \
  apt autoremove -y

USER $USERNAME
RUN git clone https://github.com/PheFreire/NeoDuckEditor.git /home/$USERNAME/.config/nvim && \
  chmod +x /home/$USERNAME/.config/nvim/setup.sh && \
  /home/$USERNAME/.config/nvim/setup.sh

# ---------------------------
# Setup do Zsh Customs
# ---------------------------

RUN git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting && \
  git clone https://github.com/denysdovhan/spaceship-prompt.git $ZSH_CUSTOM/themes/spaceship-prompt && \
  ln -s $ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme $ZSH_CUSTOM/themes/spaceship.zsh-theme

# ---------------------------
# Setup do Poetry
# ---------------------------

ENV PATH="/home/$USERNAME/.local/bin:$PATH"
RUN poetry self add poetry-plugin-shell

# ---------------------------
# Entrypoint
# ---------------------------

CMD ["zsh"]

