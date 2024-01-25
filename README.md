# folding_at_home_client

Ruby client for the [Folding@home API](https://api.foldingathome.org)

## Getting Started

Install and add to Gemfile:

```bash
bundle add folding_at_home_client
```

Install without bundler:

```bash
gem install folding_at_home_client
```

## Usage

### Users

```ruby
# Fetch count of users
FoldingAtHomeClient::Users.count

# Fetch top users of all-time
FoldingAtHomeClient::Users.top

# Fetch top users from a specific month
FoldingAtHomeClient::Users.top(month: 1, year: 2018)
```

### User

```ruby
id = "2"
name = "name"
passkey = "passkey"
team_id = "0"

# Create a user with an id, name, or both
user = FoldingAtHomeClient::User.new(id: id)
user = FoldingAtHomeClient::User.new(name: name)
user = FoldingAtHomeClient::User.new(id: id, name: name)

# Fetch a user's stats, including teams
# Required: name or id
# Optional: passkey, team_id
user.lookup
user.lookup(passkey: passkey)
user.lookup(team_id: team_id)
user.lookup(passkey: passkey, team_id: team_id)

# Fetch a user's list of contributed projects
# Required: name or id
# Optional: passkey
user.teams
user.teams(passkey: passkey)

# Fetch a user's list of contributed projects
# Required: name
user.projects

# Fetch a user's bonus stats
# Required: name
# Optional: passkey
user.bonuses
user.bonuses(passkey: passkey)
```

### Notes

Currently only `GET` endpoints are supported. It's not exhaustive because some endpoints aren't particularly useful in terms of what they return compared to other endpoints.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports, feature requests, and pull requests are welcome.

## Links

- [Folding@home](https://foldingathome.org)

- [Folding@home Download](https://foldingathome.org/start-folding)

- [Folding@home Stats](https://stats.foldingathome.org)

- [EXTREME Overclocking (EOC) Stats](https://folding.extremeoverclocking.com/aggregate_summary.php)
