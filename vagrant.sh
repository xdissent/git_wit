#!/bin/bash

sudo apt-get update
sudo apt-get install -y vim curl git build-essential nodejs libsqlite3-dev
\curl -L https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm
rvm install 1.9.3 --latest-binary
rvm use @example --create
gem install rails --no-ri --no-rdoc
rails new example --skip-bundle
cd example
echo 'gem "git_wit"' >> Gemfile
bundle
rails g git_wit:install insecure_auth insecure_write authenticate authorize_read authorize_write ssh_user:git_wit
rails s -d
mkdir repositories
git init --bare repositories/example.git
curl http://localhost:3000/example.git/HEAD
echo 'gem "tunnels"' >> Gemfile
bundle
rvmsudo tunnels 0.0.0.0:443 127.0.0.1:3000 &
curl -k https://localhost/example.git/HEAD
rails g git_wit:ssh_user
rake git_wit:ssh:debug