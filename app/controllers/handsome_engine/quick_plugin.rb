# frozen_string_literal: true
module HandsomeEngine::QuickPlugin
  extend ActiveSupport::Concern

  included do
    def self.expose(name, &block)
      define_method name do
        key = "@#{name}"
        instance_variable_set(key, instance_variable_get(key) || instance_exec(&block))
      end
    end
  end
end
