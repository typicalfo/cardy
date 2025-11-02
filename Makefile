.PHONY: help build clean test analyze run-ios run-web run-web-dev install-deps

# Default target
help:
	@echo "Business Card App - Flutter Makefile"
	@echo "====================================="
	@echo ""
	@echo "Available commands:"
	@echo "  help           - Show this help message"
	@echo "  install-deps   - Install Flutter dependencies"
	@echo "  analyze        - Run Flutter code analysis"
	@echo "  test           - Run Flutter tests"
	@echo "  build-ios      - Build iOS app"
	@echo "  build-web      - Build web app"
	@echo "  run-ios        - Run app on iOS simulator/device"
	@echo "  run-web        - Run app in Chrome (production build)"
	@echo "  run-web-dev    - Run app in Chrome (development mode)"
	@echo "  clean          - Clean build artifacts"
	@echo "  doctor         - Run Flutter doctor to check environment"

# Install dependencies
install-deps:
	@echo "Installing Flutter dependencies..."
	flutter pub get

# Run code analysis
analyze:
	@echo "Running Flutter analysis..."
	flutter analyze

# Run tests
test:
	@echo "Running Flutter tests..."
	flutter test

# Build iOS app
build-ios:
	@echo "Building iOS app..."
	flutter build ios

# Build web app
build-web:
	@echo "Building web app..."
	flutter build web

# Run on iOS
run-ios:
	@echo "Running on iOS..."
	flutter run -d ios

# Run web (production build)
run-web: build-web
	@echo "Serving web app on http://localhost:8080..."
	cd build/web && python3 -m http.server 8080

# Run web in development mode
run-web-dev:
	@echo "Running web in development mode..."
	flutter run -d chrome --web-port=8080

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	flutter clean
	rm -rf build/

# Check Flutter environment
doctor:
	@echo "Checking Flutter environment..."
	flutter doctor

# Full development setup
dev-setup: install-deps doctor analyze
	@echo "Development setup complete!"