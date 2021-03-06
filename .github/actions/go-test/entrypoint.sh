#!/bin/sh -l
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -e

download_go() {
	go_version="$(cat "${GITHUB_WORKSPACE}/GO_VERSION")"
	wget -O go.tar.gz "https://dl.google.com/go/go${go_version}.linux-amd64.tar.gz"
	tar -C /usr/local -xzf go.tar.gz
	rm go.tar.gz
	export PATH="${PATH}:${GOROOT}/bin"
	go version
}
download_go

if [ -z "$INPUT_DIR" ]; then
	# There's a bug in "defaults" for inputs
	INPUT_DIR="./lib/..."
fi

export GOPATH="$(mktemp -d)"
srcdir="$GOPATH/src/github.com/apache"
mkdir -p "$srcdir"
ln -s "$PWD" "$srcdir/trafficcontrol"
cd "$srcdir/trafficcontrol"

# Need to fetch golang.org/x/* dependencies
/usr/local/go/bin/go get -v golang.org/x/net/publicsuffix\
	golang.org/x/crypto/ed25519 \
	golang.org/x/crypto/scrypt \
	golang.org/x/net/idna \
	golang.org/x/net/ipv4 \
	golang.org/x/net/ipv6 \
	golang.org/x/sys/unix \
	golang.org/x/text/secure/bidirule
/usr/local/go/bin/go test -v $INPUT_DIR
exit $?
