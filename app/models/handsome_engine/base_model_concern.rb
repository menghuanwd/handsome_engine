# frozen_string_literal: true

module HandsomeEngine::BaseModelConcern
  extend ActiveSupport::Concern

  module ClassMethods
    def params_permit(params, excepts = [], additions = [])
      excepts << model_name.i18n_key
      params.except(*excepts).permit(permit_params + additions)
    end

    def permit_params
      column_names.map(&:to_sym) - %i[id updated_at created_at]
    end


  end
end
