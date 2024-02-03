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

# Fetch daily users (unique based on name and team_id, not user id)
# Caches the TXT file and limits fetching to every 3 hours
FoldingAtHomeClient::Users.daily
FoldingAtHomeClient::Users.daily(sort_by: :name, order: :desc)
FoldingAtHomeClient::Users.daily(limit: 5)
FoldingAtHomeClient::Users.daily(page: 1, per_page: 5)
FoldingAtHomeClient::Users.daily(name: "Anonymous")
FoldingAtHomeClient::Users.daily(team_id: 0)
FoldingAtHomeClient::Users.daily(name: "Anonymous", team_id: 0)
FoldingAtHomeClient::Users.daily(position: 10)
```

### User

```ruby
id = 2
name = "name"
passkey = "passkey"
team_id = 0

# Create a user with an id, name, or both
user = FoldingAtHomeClient::User.new(id: id)
user = FoldingAtHomeClient::User.new(name: name)
user = FoldingAtHomeClient::User.new(id: id, name: name)

# Fetch a user's stats, including teams
# Required: id or name
# Optional: passkey, team_id
user = user.lookup(id: id)
user = user.lookup(name: name)
user = user.lookup(id: id, name: name)
user = user.lookup(id: id, passkey: passkey)
user = user.lookup(id: id, team_id: team_id)
user = user.lookup(id: id, passkey: passkey, team_id: team_id)

# Fetch a user's list of contributed projects
# Required: id or name
# Optional: passkey
teams = user.teams
teams = user.teams(passkey: passkey)

# Fetch a user's list of contributed projects
# Required: name
projects = user.projects

# Fetch a user's bonus stats
# Required: name
# Optional: passkey
bonuses = user.bonuses
bonuses = user.bonuses(passkey: passkey)
```

### Teams

```ruby
# Fetch count of teams
FoldingAtHomeClient::Teams.count

# Fetch top teams from a specific month
FoldingAtHomeClient::Teams.top(month: 1, year: 2018)
```

### Team

```ruby
id = 1

# Fetch a team
# Required: id or name
team = FoldingAtHomeClient::Team.lookup(id: id)

# Fetch a teams's members
# Required: id
members = FoldingAtHomeClient::Team.new(id: id).members
```

### Projects

```ruby
# Fetch all projects
FoldingAtHomeClient::Projects.all
```

### Project

```ruby
id = 2968

project = FoldingAtHomeClient::Project.new(id: id)

# Fetch a project
# Required: id
project = project.lookup

# Fetch a project's contributors
# Required: id
contributors = project.contributors

# Fetch a project's description
# Required: description_id
description = project.description
```

### Descriptions

```ruby
# Fetch all descriptions
descriptions = FoldingAtHomeClient::Descriptions.all
```

### Description

```ruby
id = 195

# Fetch a description
# Required: id
description = FoldingAtHomeClient::Description.new(id: id).lookup
```

### Managers

```ruby
# Fetch all managers
managers = FoldingAtHomeClient::Managers.all
```

### Manager

```ruby
id = 326

# Fetch a manager
# Required: id
manager = FoldingAtHomeClient::Manager.new(id: id).lookup
```

### Causes

```ruby
# Fetch all causes
causes = FoldingAtHomeClient::Causes.all
```

### GPUs

```ruby
# Fetch all GPUs
gpus = FoldingAtHomeClient::GPUs.all
```

### GPU

```ruby
vendor = 4318
device = 5

# Fetch a GPUs
# Required: device, vendor
gpu = FoldingAtHomeClient::GPU.lookup(vendor: vendor, device: device)
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
