# GitWit

[![Build Status](https://travis-ci.org/xdissent/git_wit.png?branch=master)](https://travis-ci.org/xdissent/git_wit)

Dead simple Git hosting for Rails apps.

## Quickstart

Run `rails g git_wit:install` and checkout `config/initializers/git_wit.rb`.
You'll want to first change `config.repositories_path` to a folder where you'd
like to store your repositories. Let's use "tmp/repositories" in our app root
for fun:

```ruby
config.repositories_path = Rails.root.join("tmp", "repositories").to_s
```

Normall you wouldn't want to allow users to send their authentication 
credentials over an insecure protocol like HTTP, because they'll be sent in 
plain text over the wire. And since anonymous write access is always disallowed,
that means you can't safely push over HTTP without SSL. To disable these 
protections, something you'd **never** do in a production environment, change
the following config values in the initializer:

```
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

## SSH support

See the dummy app in `test/dummy` for a working example of `authorized_keys` 
management for the `ssh_user`.

**NOTE** To manage SSH keys, the `ssh_user` *must* be allowed to `sudo` as the
Rails application user, **and** vice versa. More documentation is forthcoming.


This project rocks and uses MIT-LICENSE.