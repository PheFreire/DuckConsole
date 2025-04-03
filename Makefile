include .env
export $(shell sed 's/=.*//' .env)

PROJECT_DIR := $(shell pwd)
IMAGE_NAME = custom-terminal
BUILD_DIR  = build

USER_NAME  := $(shell id -un)
USER_ID    := $(shell id -u)
GROUP_ID   := $(shell id -g)

build: prepare-zshrc
	@echo "📦 Buildando imagem Docker: $(IMAGE_NAME)..."
	docker build \
		--build-arg USERNAME=$(USER_NAME) \
		--build-arg USER_UID=$(USER_ID) \
		--build-arg USER_GID=$(GROUP_ID) \
		-t $(IMAGE_NAME) $(BUILD_DIR)

term:
	@echo "🚀 Iniciando terminal no diretório atual: $(PWD)"
	docker run -it --rm \
		-v $(PWD):$(PWD) \
		-w $(PWD) \
		-v $$SSH_AUTH_SOCK:/ssh-agent \
		-e SSH_AUTH_SOCK=/ssh-agent \
		--user $(shell id -u):$(shell id -g) \
		$(IMAGE_NAME)

clean:
	@echo "🧹 Limpando arquivos gerados..."
	@rm -f $(BUILD_DIR)/.zshrc

prepare-zshrc:
	@mkdir -p $(BUILD_DIR)
	@if [ "$(ZSHRC_SOURCE)" = "local" ]; then \
		echo "🔧 Usando .zshrc local..."; \
		cp .zshrc $(BUILD_DIR)/.zshrc; \
	elif [ -n "$(ZSHRC_SOURCE)" ]; then \
		echo "📦 Copiando .zshrc de $(ZSHRC_SOURCE)..."; \
		cp $(ZSHRC_SOURCE) $(BUILD_DIR)/.zshrc; \
	else \
		echo "⚠️ Nenhum .zshrc fornecido. Gerando arquivo vazio..."; \
		touch $(BUILD_DIR)/.zshrc; \
	fi

setup:
	@echo "🛠️  Instalando dependências do host para rodar o Docker..."

	@sudo apt-get update -y
	@sudo apt-get install -y \
		curl git make apt-transport-https ca-certificates gnupg lsb-release

	@echo "🐳 Instalando Docker (Engine + CLI)..."
	@sudo mkdir -p /etc/apt/keyrings
	@curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

	@echo "📦 Adicionando repositório oficial do Docker..."
	@echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
	https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	@sudo apt-get update -y
	@sudo apt-get install -y \
		docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	@echo "👤 Adicionando usuário '$$(whoami)' ao grupo docker..."
	@sudo usermod -aG docker $$(whoami)

	@echo "🔗 Configurando alias 'term' no shell do host..."
	@SHELL_NAME="$$(basename $$SHELL)"; \
	case $$SHELL_NAME in \
		zsh) CONFIG_FILE="$$HOME/.zshrc";; \
		bash) CONFIG_FILE="$$HOME/.bashrc";; \
		*) CONFIG_FILE="$$HOME/.profile";; \
	esac; \
	ALIAS_LINE='alias term="make -C $(PROJECT_DIR) term"'; \
	if [ ! -f "$$CONFIG_FILE" ]; then \
		echo "📄 Criando arquivo de configuração: $$CONFIG_FILE"; \
		touch "$$CONFIG_FILE"; \
	fi; \
	if ! grep -Fxq "$$ALIAS_LINE" "$$CONFIG_FILE"; then \
		echo "$$ALIAS_LINE" >> "$$CONFIG_FILE"; \
		echo "✅ Alias adicionado a $$CONFIG_FILE"; \
	else \
		echo "ℹ️  Alias 'term' já existe em $$CONFIG_FILE"; \
	fi

	@echo "✅ Setup concluído!"
	@echo "ℹ️  Faça logout/login ou execute 'newgrp docker' para aplicar as permissões."

