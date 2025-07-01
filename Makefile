build_runner:
	dart run build_runner build --delete-conflicting-outputs

clean:
	dart run build_runner clean && flutter clean