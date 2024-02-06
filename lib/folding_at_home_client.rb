# frozen_string_literal: true

require_relative 'folding_at_home_client/version'

require 'faraday'
require 'json'

# Helper
require_relative 'folding_at_home_client/request'

# Classes
require_relative 'folding_at_home_client/causes'
require_relative 'folding_at_home_client/description'
require_relative 'folding_at_home_client/gpu'
require_relative 'folding_at_home_client/manager'
require_relative 'folding_at_home_client/project'
require_relative 'folding_at_home_client/team'
require_relative 'folding_at_home_client/user'

# Modules
require_relative 'folding_at_home_client/descriptions'
require_relative 'folding_at_home_client/gpus'
require_relative 'folding_at_home_client/managers'
require_relative 'folding_at_home_client/projects'
require_relative 'folding_at_home_client/teams'
require_relative 'folding_at_home_client/users'
