#!/usr/bin/env bash
set -e
set -x
test -z "$(git status --porcelain)"
GIT_HASH=$( git rev-parse HEAD )
CURDIR=$(cd $(dirname "$0") && pwd)
SITE_DIR=$1
GH_REMOTE="git@github.com:snaekobbi/snaekobbi.github.io.git"
GH_BRANCH=master
TMP_DIR=$( mktemp -t "$(basename "$0").XXXXXX" )
rm $TMP_DIR
git clone --branch $GH_BRANCH --depth 1 $GH_REMOTE $TMP_DIR
cd $TMP_DIR
git rm -r *
cp -r $CURDIR/$SITE_DIR/* .
git add .
git commit -m "publish site [ commit ${GIT_HASH} ]"
git push $GH_REMOTE master:$GH_BRANCH
cd $CURDIR
rm -rf $TMP_DIR
