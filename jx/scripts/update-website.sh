#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo "updating the CLI reference"
git clone https://github.com/jenkins-x/jx-docs.git

pushd jx-docs/content/en/docs/reference/commands
  ../../../../../../build/linux/jx create docs
  git config credential.helper store
  git add *
  git commit --allow-empty -a -m "updated jx commands & API docs from $VERSION"
  git fetch origin && git rebase origin/master
popd


echo "Updating the JSON Schema"
pushd jx-docs/content
  mkdir -p schemas
  cd schemas
  ../../../build/linux/jx step syntax schema -o jx-schema.json
  ../../../build/linux/jx step syntax schema --requirements -o jx-requirements.json
  git add *
  git commit --allow-empty -a -m "updated jx Json Schema from $VERSION"
  git fetch origin && git rebase origin/master
popd

echo "Updating the JX CLI & API reference docs"
make generate-docs
cp -r docs/apidocs/site jx-docs/static/apidocs

pushd jx-docs/static/apidocs
  git add *
  git commit --allow-empty -a -m "updated jx API docs from $VERSION"
  git fetch origin && git rebase origin/master
popd

pushd jx-docs
  git push origin
popd
