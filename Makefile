DOTFILES := $(filter-out . .. .git .gitignore,$(wildcard .??*))

.PHONY: all link clean

all: link

link:
	@echo "🔗 Linking dotfiles to $(HOME)..."
	@for file in $(DOTFILES); do \
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
	@for file in $(DOTFILES); do \
		dest="$(HOME)/$$file"; \
		if [ -L "$$dest" ]; then \
			rm "$$dest"; \
			echo "  ❌ Removed symlink: $$dest"; \
		elif [ -e $$dest ]; then \
			echo "  ⚠️ Skipping (file already exists): $$dest"; \
			continue; \
		fi; \
	done