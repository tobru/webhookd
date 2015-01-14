# Webhooker

**Flexible, configurable universal webhook receiver**

This app is a flexible, configurable universal webhook receiver, built with
sinatra.
It can receive a webhook, parse its payload and take action according to the
configuration.

Example: A git push to Gitlab sends a webhook to the webhooker. The webhooker then
parses the payload which contains the name and the branch of the pushed commit.
After that it looks up in the configuration what to do: run a different script per
repo or even per branch.

## Installation

Just install the GEM:

    $ gem install webhooker

## Usage

### Starting and stopping

The webhooker uses thin as rack server by default. It has a small CLI utility
to start and stop the service, called `webhooker`:

```
Commands:
  webhooker help [COMMAND]  # Describe available commands or one specific command
  webhooker start           # Starts the webhooker server
  webhooker stop            # Stops the thin server
```

To see the options for `thin`, run `webhooker start -h`. They can simply be added to the `start` command.
F.e. `webhooker start -d --config-file=/path/to/config.yml`

**Starting the webhooker server**

`webhooker start --config-file=/path/to/config.yml`

**Stopping the webhooker server**

`webhooker stop`

### Configuration

The configuration is written in YAML. To see an example have a look at `etc/example.yml`.

**Global configuration**   
This section holds some global parameters:

```YAML
global:
  loglevel: 'debug'
  logfile: 'app.log'
  username: 'deployer'
  password: 'Deploy1T'
```

* *loglevel*: One of: debug, info, warn, error, fatal
* *logfile*: Path (including filename) to the application log
* *username*: Username for the basic authentication to the application
* *password*: Password for the basic authentication to the application

**Payload type specific configuration**   
Per payload type configuration. Available payload types: vcs. (More to come)

**Payload type 'vcs'**   
This is meant for payload types coming from a version control system like git.

```YAML
vcs:
  myrepo:
    _all:
      command: 'echo _all with branch <%= branch_name %>'
    production:
      command: '/usr/local/bin/deploy-my-app'
    otherbranch:
      command: '/bin/true'
  myotherrepo:
    master:
      command: 'cd /my/local/path; /usr/bin/git pull'
  _all:
    master:
      command: 'echo applies to all master branches of not specifically configured repos'
    _all:
      command: 'echo will be applied to ALL repos and branches if not more specifically configured'
```

There should be an entry per repository. If needed there can be a catch-all name which applies
to all repositories: `_all`. On the next level comes the name of the branch. Here could also be a
catch-all name specified, also called `_all`.

The `command` parameter can include the ERB snippet `<%= branch_name %>` which is replaced with
the current branch name.

### Testing

There are some tests in place using `minitest`. Run `rake test` to run all available test.
It should output a lot of log messages and at the end a summary of all test without any errors.
For the testcases to succeed, the configuration file `etc/example.yml` is used.

## Contributing

1. Fork it ( https://github.com/tobru/webhooker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Payload types

Payload types are part of the business logic in `lib/webhooker/app.rb`.
It is defined in the payload endpoint in `lib/webhooker/payloadtype/<payloadtype>.rb`.
For an example have a look at `lib/webhooker/payloadtype/bitbucket.rb`.

Adding a new type would involve the following steps:
1. Write a payload parser in `lib/webhooker/payloadtype/`
1. Add business logic for the payload type in `lib/webhooker/app.rb` under `case parsed_data[:type]`

### Payload parser

The payload parser parses the payload data received from the webhook sender into a standard hash
which will be consumed by the business logic to take action.

**vcs**

The `vcs` payload type has the following hash signature:

```ruby
data[:type]
data[:source]
data[:repo_name]
data[:branch_name]
data[:author_name]
```

