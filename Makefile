.PHONY: build_runner clean get watch analyze test help

# Default target
help:
	@echo "Available commands:"
	@echo "  make get           - Get dependencies"
	@echo "  make build_runner  - Run build_runner once"
	@echo "  make watch         - Run build_runner in watch mode"
	@echo "  make clean         - Clean build cache and Flutter"
	@echo "  make analyze       - Analyze code"
	@echo "  make test          - Run tests"

# Get dependencies
get:
	flutter pub get

# Run build_runner once
build_runner: get
	dart run build_runner build --delete-conflicting-outputs

# Run build_runner in watch mode (useful during development)
watch: get
	dart run build_runner watch --delete-conflicting-outputs

# Clean everything
clean:
	dart run build_runner clean
	flutter clean
	flutter pub get

# Analyze code
analyze:
	flutter analyze

# Run tests
test:
	flutter test