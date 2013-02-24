# GitWit

[![Build Status](https://travis-ci.org/xdissent/git_wit.png?branch=master)](https://travis-ci.org/xdissent/git_wit)
[![Gem Version](https://badge.fury.io/rb/git_wit.png)](http://badge.fury.io/rb/git_wit)

Dead simple Git hosting for Rails apps.

## Crash Course

Start hosting git repositories in seconds. Create a new Rails app and 
install GitWit:

```console
$ rails new example --skip-bundle; cd example       # New Rails app
$ echo 'gem "git_wit"' >> Gemfile; bundle           # Install git_wit gem
$ rails g git_wit:install insecure_auth insecure_write authenticate authorize_read authorize_write
$ rails s -d  # <- Start Rails server               # ^- Install/config GitWit
```

That's it - your app is hosting git repositories. Create a repositories folder,
init a bare repo, and push to it:

```console
$ git init; git add .; git commit -m "That was easy"
$ mkdir repositories                                # Hosted repos folder
$ git init --bare repositories/example.git          # Example bare repo
$ git remote add origin http://localhost:3000/example.git
$ git push origin master  # Push example app to itself to store in itself!
```

HTTPS? That works too:

```console
$ sudo echo "pre-loading sudo so we can background tunnels in a moment"
$ rails g git_wit:install authenticate authorize_read authorize_write -f
$ echo 'gem "tunnels"' >> Gemfile; bundle
$ sudo tunnels 443 3000 &       # or `rvmsudo tunnels...` if using RVM
$ git remote add https https://localhost/example.git
$ GIT_SSL_NO_VERIFY=1 git push https master:https-master  # Trust yourself
```

Still not impressed? Try SSH:

```console
$ rails g git_wit:install authenticate authorize_read authorize_write ssh_user:git_wit -f
$ rails g git_wit:ssh_user      # Creates/configs git_wit SSH user
$ rake git_wit:ssh:add_key      # Grant access for ~/.ssh/id_rsa.pub
$ git remote add ssh git_wit@localhost:example.git
$ git push ssh master:ssh-master
```

You might want to get rid of that system user you just created:

```console
$ rails d git_wit:ssh_user
```


## Overview

GitWit adds git hosting abilities to any Rails app. It provides configurable
authentication and authorization methods that can be integrated with any 
user/repository access model you'd like. All configuration is handled through a
single initializer, 
[`config/initializers/git_wit.rb`](https://github.com/xdissent/git_wit/blob/master/lib/generators/git_wit/templates/git_wit.rb). 
Run `rails g git_wit:install` to generate a default configuration for 
modification. All configuration details are contained within comments inside
the initializer, or read on for the highlights.


## Authentication

Normally GitWit prevents the user from sending authentication credentials in
plaintext (via HTTP without SSL). To disable these protections, something you'd 
**never** do in a production environment, change the following config values 
in the initializer:

```ruby
config.insecure_auth = true
config.insecure_write = true
```

Authentication is handled by the `config.authenticate` attribute. A valid
authenticator is any callable that accepts a user model instance and a 
clear-text password. The authenticator should return a boolean response 
indicating whether the user is authenticated for the given password. To allow
any user as long as the password matches the username:

```ruby
config.authenticate = ->(user, password) do
  user == password
end
```

The user model is simply the username as a string by default. Before passing
the user to the authenticator, GitWit will call `config.user_for_authenication`,
passing it the username and expecting a new user model instance in return. For
example:

```ruby
config.user_for_authentication = ->(username) do
  User.active.find_by_login username: username
end
```

Now the `config.authenticate` authenticator will recieve the `User` instance:

```ruby
config.authenticate = ->(user, password) do
  user.valid_password? password   # user is a User
end
```


## Authorization

Two configuration attributes are responsible for authorization: 
`config.authorize_read` and `config.authorize_write`. They're passed the user 
instance (already authenticated) and the repository path as a string. The 
repository path is relative to `config.repositories_path` 
(`<app root>/repositories` by default). The authorizers should return a boolean
to grant or deny access accordingly. A simple example:

```ruby
config.authorize_read = ->(user, repository) do
  %w(reader writer).include?(user)
end

config.authorize_write = ->(user, repository) do
  user == "writer"
end
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
and the `ssh_user` only needs to know how to call the `git_wit git-shell` 
command.

GitWit comes with an initializer to set everything up for you. First, enable the 
`ssh_user` config in `config/initializers/git_wit.rb`:

```ruby
config.ssh_user = "git_wit"
```

Now run the initializer:

```console
$ rails g git_wit:ssh_user
```

To add a public key: `rake git_wit:ssh:add_key`

Something not working? `rake git_wit:ssh:debug`


## Git hooks and configs and umasks and everything

Dude, your app owns the repos now. Hooks are just files again! Rediscover the
[grit](https://github.com/mojombo/grit) gem and go nuts with all kinds of fun
stuff that used to be a serious pain. Paranoid? Lock down the permissions on
your repositories folder so that only your application user can read it. The
SSH shell will still be executed as the application user so it's no sweat.


This project rocks and uses MIT-LICENSE.