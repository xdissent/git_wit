# GitWit

[![Build Status](https://travis-ci.org/xdissent/git_wit.png?branch=master)](https://travis-ci.org/xdissent/git_wit)
[![Gem Version](https://badge.fury.io/rb/git_wit.png)](http://badge.fury.io/rb/git_wit)

Dead simple Git hosting for Rails apps.

## Quickstart

Create a Rails 3.2 app if you don't already have one. Add `gem "git_wit"` to 
your `Gemfile` and run `bundle install`. Now run 
`rails g git_wit:install` and configure GitWit by editing 
[`config/initializers/git_wit.rb`](https://github.com/xdissent/git_wit/blob/master/lib/generators/git_wit/templates/git_wit.rb). 
You'll want to first change `config.repositories_path` to a folder where you'd 
like to store your repositories. Let's use "tmp/repositories" in our app root 
for fun:

```ruby
config.repositories_path = Rails.root.join("tmp", "repositories").to_s
```

Normally GitWit prevents the user from sending authentication credentials in
plaintext (via HTTP without SSL). To disable these 
protections for now, something you'd **never** do in a production environment, 
change the following config values in the initializer:

```ruby
config.insecure_auth = true
config.insecure_write = true
```

Now let's set up some simple (fake) authentication and authorization:

```ruby
config.authenticate = ->(user, password) do
  %w(reader writer).include?(user) && user == password
end

config.authorize_read = ->(user, repository) do
  %w(reader writer).include?(user)
end

config.authorize_write = ->(user, repository) do
  user == "writer"
end
```

What we've done is effectively create two users: `reader` and `writer`. Both can
read all repositories, but only `writer` may write (and can write to any repo.)
Both users are considered authenticated if the password matches the username.

Now your app is ready to start serving git repos over HTTP. Just create the 
repositories folder, initialize a repo and start the server:

```console
$ mkdir -p tmp/repositories
$ git init --bare tmp/repositories/example.git
$ rails s
```

Clone your repo, make some changes, and push:

```console
$ git clone http://localhost:3000/example.git
$ cd example
$ touch README
$ git add README
$ git commit -m "First"
$ git push origin master
```

Your server will ask you for a username and password when you push - use 
`writer` for both and it should accept your changes.


## SSL

You **really** should turn `insecure_auth` and `insecure_write` back to `false`
as quickly as possible and enable SSL for read/write access. GitWit doesn't 
need any special SSL configuration - just flip SSL on in whatever web server
is running Rails. You can also use the 
[tunnels](https://github.com/jugyo/tunnels) gem to run your app with SSL in 
development. Just add it to the Gemfile and run `bundle install` followed by
`sudo tunnels` (or `rvmsudo tunnels` for RVM). For `rails s`, which runs on
port 3000 by default, run `sudo tunnels 443 3000`. Now you may clone 
repositories over HTTPS:

```console
$ git clone https://localhost/example.git
```


## A quick note about "local requests"

The default Rails development environment has a config value called 
`consider_all_requests_local`, which is `true`. This prevents GitWit from 
correctly handling authentication responses in some cases. It's not a big deal,
you'll just be asked to re-authenticate more often and some responses will be
slightly misleading. But the alternative solution, which is to set 
`consider_all_requests_local` to `false`, disables any special Rails error 
handling - quite a bummer for development. It would be nice to sort this out a
little better in the future. Note that the production environment uses `false`
by default and handles errors appropriately.


## Advanced Usage (Devise, Cancan, etc.)

See [`test/dummy`](https://github.com/xdissent/git_wit/tree/master/test/dummy) 
for an example app that integrates 
[Devise](https://github.com/plataformatec/devise), 
[Cancan](https://github.com/ryanb/cancan), 
[rolify](https://github.com/EppO/rolify) and
[twitter-bootstrap-rails](https://github.com/seyhunak/twitter-bootstrap-rails). 
Example controllers for managing repositories and public keys are included.


## SSH support - AKA: The hard part

To enable git operations over SSH, you **must have a dedicated SSH user**. This
user will *only* be used for SSH authentication. Immediately after successfully
authenticating, the SSH user will `sudo` to the application user to continue
with the git operation. This eliminates the need for all the bat-shit crazy git
pulls/pushes and SSH wrappers and crap that are typical of gitolite/gitosis
setups. Your application user owns everything except the `authorized_keys` file
and the `ssh_user` only needs to know how to call the `gw-shell` command.

First, create a dedicated SSH user. On Mountain Lion:

```console
$ sudo dscl . -create /Groups/gitwit
$ sudo dscl . -create /Groups/gitwit PrimaryGroupID 333
$ sudo dscl . -create /Groups/gitwit RealName "GitWit Server"
$ sudo dscl . -create /Users/gitwit UniqueID 333
$ sudo dscl . -create /Users/gitwit PrimaryGroupID 333
$ sudo dscl . -create /Users/gitwit NFSHomeDirectory /var/gitwit
$ sudo dscl . -create /Users/gitwit UserShell /bin/bash
$ sudo dscl . -create /Users/gitwit RealName "GitWit Server"
$ sudo mkdir -p ~gitwit
$ sudo chown -R gitwit:gitwit ~gitwit
```

Enable the `ssh_user` config value in `config/initializers/git_wit.rb`:

```ruby
config.ssh_user = "gitwit"
```

Now your application user needs to be allowed to `sudo` as `ssh_user` and vice
versa. Edit `/etc/sudoers` using `sudo visudo` and add the following lines:

```
# Note: The following lines *must* appear *after* `Defaults env_reset`!
# Allow gitwit to pass the following environment variables to sudo processes:
Defaults:gitwit env_keep += "SSH_ORIGINAL_COMMAND GEM_HOME GEM_PATH"
Defaults:gitwit env_keep += "BUNDLE_GEMFILE RAILS_ENV RAILS_ROOT"

# Allow rails_user to run any command as gitwit
rails_user ALL=(gitwit) NOPASSWD:ALL

# Allow gitwit to run *only* gw-shell as rails_user
gitwit ALL=(rails_user) NOPASSWD:/full/path/to/bin/gw-shell
```

Replace `rails_user` with the application under which your Rails app runs, which
will be your personal username if using `rails s` or Pow.

Test your `sudo` rights and initialize the `ssh_user` environment:

```console
$ sudo -u gitwit -i
$ mkdir .ssh
$ chmod 700 .ssh
$ touch .ssh/authorized_keys
$ chmod 600 .ssh/authorized_keys
```

If you're using RVM or some other wacky environment manipulating tool, you're 
going to want to adjust the login environment for `ssh_user` by creating a
`~ssh_user/.bashrc` file. For example, to load a specific RVM gemset:

```bash
source "/Users/xdissent/.rvm/environments/ruby-1.9.3-p385@git_wit"
```

You may also need to adjust the `PATH` to include the location of the `gw-shell`
executable. If you're using `bundle --binstubs` for example:

```bash
export PATH="/path/to/app/bin:$PATH"
```

The `gw-shell` command handles the authentication and authorization for the SSH
protocol. It is initially called by `ssh_user` upon login (git operation) and it
will attempt to `sudo` to the application user and re-run itself with the same
environment. It determines which user is the "application user" by looking at
who owns the rails app root folder. To determine where the app root is actually
located, it looks for the ENV variables `RAILS_ROOT` and `BUNDLE_GEMFILE` in 
order. When in doubt, set `RAILS_ROOT` in `~ssh_user/.bashrc`:

```bash
export RAILS_ROOT="/path/to/app"
```

**Remember to add `export RAILS_ENV="production"` for production deployments!**

You can easily sanity check your environment using `sudo` as your app user:

```console
$ sudo -u gitwit -i
$ source .bashrc
$ which gw-shell
/Users/xdissent/Code/git_wit/stubs/gw-shell
$ echo $RAILS_ROOT
/Users/xdissent/Code/git_wit/test/dummy
```

Now all that's left to do is add some `authorized_keys` and you're all set. 
This can be done from the rails console (`rails c`):

```ruby
GitWit.add_authorized_key "writer", "ssh-rsa long-ass-key-string writer@example.com"
# => nil 
GitWit.authorized_keys_file.keys
# => [command="gw-shell writer",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa long-ass-key-string writer@example.com] 
```

You may now clone/push/pull over SSH - assuming the key you installed for 
`writer` is known to your ssh agent (ie `~/.ssh/id_rsa`):

```console
$ git clone gitwit@localhost:example.git
```

See the dummy app in 
[`test/dummy`](https://github.com/xdissent/git_wit/tree/master/test/dummy) for 
a more advanced example of `authorized_keys` management.


## Git hooks and configs and umasks and everything

Dude, your app owns the repos now. Hooks are just files again! Rediscover the
[grit](https://github.com/mojombo/grit) gem and go nuts with all kinds of fun
stuff that used to be a serious pain. Paranoid? Lock down the permissions on
your repositories folder so that only your application user can read it. The
SSH shell will still be executed as the application user so it's no sweat.


This project rocks and uses MIT-LICENSE.