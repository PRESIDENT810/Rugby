#!/bin/bash

set -e

header() {
	printf "\e[33m>\e[m \e[32mStep: $1\e[m\n"
}

header "CocoaPods"
pod install --repo-update

header "Rugby"
rugby cache --output multiline

header "Test"
SIMULATOR_ID=`xcrun simctl list devices | grep -m 1 'iPhone 14 (' | grep -oE '[0-9A-Z\-]{20,}'`
xcrun simctl shutdown all
xcrun simctl boot $SIMULATOR_ID
set -o pipefail && env NSUnbufferedIO=YES arch -arm64 xcodebuild clean test \
  -workspace Example.xcworkspace \
  -scheme Example \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=${SIMULATOR_ID}" \
  -derivedDataPath build \
  COMPILER_INDEX_STORE_ENABLE=NO \
  SWIFT_COMPILATION_MODE=wholemodule \
  | xcbeautify