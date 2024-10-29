install:
	bash install.sh

update:
	@echo "Atualizando pacotes e ferramentas..."
ifeq ($(shell test -f /etc/debian_version && echo debian || echo redhat), debian)
	sudo apt update && sudo apt upgrade -y
else
	sudo dnf check-update && sudo dnf upgrade -y
endif
