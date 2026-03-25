DOTFILES := $(filter-out . .. .git .gitignore .config .DS_Store .oh-my-zsh .claude,$(wildcard .??*))
CONFIGFILES := $(shell find .config -type f 2>/dev/null)
ZSHTHEMES := $(shell find .oh-my-zsh .zsh-theme -type f 2>/dev/null)
INSTRUCTIONFILES := $(shell find .claude -type f 2>/dev/null)
ALLFILES := $(DOTFILES) $(CONFIGFILES) $(ZSHTHEMES) $(INSTRUCTIONFILES)

.PHONY: all link clean

all: link

link:
	@echo "🔗 Linking dotfiles to $(HOME)..."
	@for file in $(ALLFILES); do \
		mkdir -p "$$(dirname "$(HOME)/$$file")"; \
		dest="$(HOME)/$$file"; \
		if [ -L "$$dest" ]; then \
			echo "  🔁 Replacing existing symlink: $$dest"; \
			rm "$$dest"; \
		elif [ -e "$$dest" ]; then \
			echo "  ⚠️ Skipping (file already exists): $$dest"; \
			continue; \
		fi; \
		ln -s "$$(pwd)/$$file" "$$dest"; \
		echo "  ✅ Linked $$file → $$dest"; \
	done

clean:
	@echo "🧹 Removing dotfile symlinks from $(HOME)..."
	@for file in $(ALLFILES); do \
		dest="$(HOME)/$$file"; \
		if [ -L "$$dest" ]; then \
			rm "$$dest"; \
			echo "  ❌ Removed symlink: $$dest"; \
		elif [ -e $$dest ]; then \
			echo "  ⚠️ Skipping (file already exists): $$dest"; \
			continue; \
		fi; \
	done
