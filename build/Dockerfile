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
# Configuração do ambiente
# ---------------------------

# Instala oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Configura ambiente pyenv
ENV PYENV_ROOT="/home/$USERNAME/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH"

# ---------------------------
# Instalação de ferramentas
# ---------------------------

# Instala ferramentas do usuário
RUN curl https://pyenv.run | bash \
  && curl https://sh.rustup.rs -sSf | sh -s -- -y

# Instala nvm, node, yarn e typescript
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
  export NVM_DIR="$HOME/.nvm" && \
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
  nvm install --lts && npm install -g yarn typescript

# Instala poetry + adiciona ao zsh
RUN curl -sSL https://install.python-poetry.org | python3 - && \
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> /home/$USERNAME/.zshrc
ENV PATH="/home/$USERNAME/.local/bin:$PATH"

RUN pip install --no-cache-dir pyright

# ---------------------------
# Setup do Neovim
# ---------------------------

RUN git clone https://github.com/PheFreire/NeoDuckEditor.git /home/$USERNAME/.config/nvim && \
  chmod +x /home/$USERNAME/.config/nvim/setup.sh && \
  /home/$USERNAME/.config/nvim/setup.sh

# ---------------------------
# Entrypoint
# ---------------------------

CMD ["zsh"]

