.PHONY: setup dev build start test check format devices android ios
setup:
	flutter pub get --enforce-lockfile
	dart run tool/project.dart configure
dev:
	dart run tool/project.dart dev
build:
	dart run tool/project.dart build
start:
	dart run tool/project.dart start
test:
	dart run tool/project.dart test
check:
	dart run tool/project.dart check
format:
	dart run tool/project.dart format
devices:
	flutter devices
android:
	dart run tool/project.dart build-android
ios:
	dart run tool/project.dart build-ios
