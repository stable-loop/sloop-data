# frozen_string_literal: true

module Data
  module DataHelper
    def action?(action_name) = params[:action] == action_name.to_s

    def data_path_for(object, action = :show)
      return url_for(controller: "data/#{object.base_class.name.pluralize.underscore}", action:) if object.is_a?(Class)

      url_for(controller: "data/#{object.class.base_class.name.pluralize.underscore}", action:, id: object.id)
    end

    def form_field(type)
      case type
      when :boolean then :check_box
      when :datetime then :datetime_local_field
      when :integer then :number_field
      else
        :text_field
      end
    end

    def data_records
      data_controller_files = Dir.glob(Rails.root.join("app/controllers/data/*_controller.rb"))
      data_controller_files.map do |file|
        controller_filename = File.basename(file, ".rb")
        next if controller_filename.in? %w[application_controller attachments_controller]

        klass_name = controller_filename.chomp("_controller").singularize
        klass = klass_name.classify.safe_constantize
        locale = "#{klass_name.underscore}.#{klass_name.pluralize.underscore}"
        [klass, locale]\
      end.compact.sort_by!(&:second)
    end

    def subclasses_of(klass)
      Rails.application.eager_load!
      ApplicationRecord.descendants.select { |_| _ < klass }.map(&:name)
    end
  end
end
