install:
	@chmod +x install.sh
	@bash install.sh

update:
	@echo "Atualizando pacotes..."
ifeq ($(shell test -f /etc/debian_version && echo debian || echo redhat), debian)
	@sudo apt update >/dev/null 2>&1 && sudo apt upgrade -y >/dev/null 2>&1 && echo "Atualização concluída!" || echo "Erro durante a atualização."
else
	@sudo dnf check-update >/dev/null 2>&1 && sudo dnf upgrade -y >/dev/null 2>&1 && echo "Atualização concluída!" || echo "Erro durante a atualização."
endif
