require 'kaminari'
require 'pg'
require 'oj'
require 'pry-rails'
require 'rspec-rails'
require 'rswag'
require 'rails_param'
require 'aasm'
require 'sidekiq'
require 'annotate'

module HandsomeEngine
  class Engine < ::Rails::Engine
    isolate_namespace HandsomeEngine

    initializer "handsome.config.initializer" do |app|
      app.config.load_defaults 6.0
      app.config.time_zone = 'Asia/Shanghai'
      app.config.eager_load_paths += %W(./lib)

      app.config.generators do |g|
        g.helper false
        g.assets false
        g.view_specs false
        g.template_engine :jbuilder
        g.scaffold_stylesheet false
        g.factory_bot dir: 'spec/factories'
        g.fixture_replacement :factory_bot, dir: 'spec/factories'
        g.test_framework :rspec,
                         controller_specs: false,
                         fixtures: true,
                         view_specs: false,
                         helper_specs: false,
                         routing_specs: false,
                         request_specs: false

      end
    end

    # config.to_prepare do
    #   Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb").each do |c|
    #     require_dependency(c)
    #   end
    # end

  end
end
