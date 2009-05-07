if RAILS_ENV == "test"

  require 'remarkable_activerecord'

  require File.join(File.dirname(__FILE__), "lib", "remarkable_you_name_it")

  require 'spec'
  require 'spec/rails'

  Remarkable.include_matchers!(Remarkable::YouNameIt, Spec::Rails::Example::ModelExampleGroup)

end