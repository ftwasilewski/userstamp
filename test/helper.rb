require 'rubygems'

$LOAD_PATH.unshift('lib')

# load normal stuff
require 'active_support'
require 'active_record'
require 'action_controller'
require 'init'
require 'pry'

# connect to db
ActiveRecord::Base.establish_connection({
  :adapter => "sqlite3",
  :database => ":memory:",
})
require 'test/schema'

# load test framework
require 'test/unit'
begin
  require 'redgreen'
rescue LoadError
end
require 'active_support/test_case'
require 'action_controller/test_case'
# require 'action_controller/test_process'
# require 'action_controller/integration'

# load test models/controllers
require 'test/controllers/userstamp_controller'
require 'test/controllers/users_controller'
require 'test/controllers/posts_controller'
require 'test/models/user'
require 'test/models/person'
require 'test/models/post'
require 'test/models/foo'

# ActionController::Routing::Routes.draw do |map|
#   map.connect ':controller/:action/:id'
# end
