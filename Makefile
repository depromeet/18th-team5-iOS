.PHONY: setup generate clean reset

setup:
	@echo "🔧 개발 환경 설정을 시작합니다..."
	@# 1. Homebrew 설치 확인 및 자동 설치
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "📦 Homebrew 설치 중..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		if [ -f /opt/homebrew/bin/brew ]; then \
			eval "$$(/opt/homebrew/bin/brew shellenv)"; \
		elif [ -f /usr/local/bin/brew ]; then \
			eval "$$(/usr/local/bin/brew shellenv)"; \
		fi; \
	fi
	@# 2. mise 설치 확인 및 자동 설치
	@if ! command -v mise >/dev/null 2>&1; then \
		echo "📦 mise 설치 중..."; \
		brew install mise; \
	fi
	@eval "$$(mise activate bash --shims)" && mise install
	@# 3. Node.js 확인 및 자동 설치 (husky, gitmoji-cli에 필요)
	@if ! command -v node >/dev/null 2>&1; then \
		echo "📦 Node.js 설치 중..."; \
		eval "$$(mise activate bash --shims)" && mise use -g node@lts; \
	fi
	@# 4. npm 의존성 설치 (husky + gitmoji-cli)
	npm install
	@# 5. Tuist 프로젝트 생성
	make generate
	@echo ""
	@echo "✅ 환경 설정 완료!"
	@echo ""
	@echo "⚠️  mise 쉘 활성화가 필요합니다. 아래 명령어를 ~/.zshrc에 추가해주세요:"
	@echo '  eval "$$(mise activate zsh)"'
	@echo ""
	@echo "추가 후 터미널을 재시작하거나 'source ~/.zshrc'를 실행해주세요."

generate:
	eval "$$(mise activate bash --shims)" && tuist install
	eval "$$(mise activate bash --shims)" && tuist generate

clean:
	rm -rf Projects/**/*.xcodeproj
	rm -rf Projects/**/Derived
	rm -rf *.xcworkspace

reset:
	tuist clean
	@if [ -e ./Tuist/Package.resolved ] ; then \
		rm Tuist/Package.resolved; \
	fi
	make clean
