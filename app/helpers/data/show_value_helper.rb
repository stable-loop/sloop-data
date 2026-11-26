# frozen_string_literal: true

class Data
  module ShowValueHelper
    def max_index_cell_length = 50

    def show_value(attribute, value)
      return yes_no_tag(value) if boolean?(value)
      return link(attribute, value) if link?(attribute)
      return format_time(value) if time?(value)
      return format_datetime(value) if datetime?(attribute)
      return format_date(value) if date?(attribute)
      return show_path_for(attribute, value) if model_id?(attribute, value)
      return value.join(", ") if value.is_a?(Array)
      return format_json(value) if json?(value)
      return value.capitalize if attribute == "status"
      return color_badge(value) if attribute == "color"

      value
    end

    def show_path_for(attribute, value)
      object = attribute.delete_suffix("_id").classify.constantize.find(value)
      link_to object, data_path_for(object)
    end

    def yes_no(bool) = bool ? "Yes" : "No"
    def yes_no_tag(bool) = text_tag(yes_no(bool), bool:)

    def checkbox_badge(bool, green_text: nil, red_text: nil, title: nil)
      text_tag((bool ? green_text : red_text), bool:, title:)
    end

    def text_tag(text, bool: true, spinner: false, title: nil)
      color = bool ? "success" : "danger"
      tag_class = "badge"
      tag_class += " text-bg-#{color}"
      return unless text

      tag.span class: tag_class, title: title || text do
        concat text
        concat(image_tag("loading.gif", style: "margin-left: 5px;width: 25px;")) if spinner
      end
    end

    def format_time(value) = value&.strftime("%H:%M")

    def link(attribute, value)
      return "" if value.blank?

      link_to value, title: attribute.to_s.humanize, target: "_blank" do
        tag :i, class: "bi bi-box-arrow-up-right"
      end
    end

    def format_datetime(value) = value&.strftime("%Y-%m-%d %H:%M:%S")
    def format_date(value) = value&.strftime("%Y-%m-%d")
    def format_json(value) = JSON.parse(value).to_yaml
    def color_badge(value) = tag.span value, class: "badge", title: value, style: "background-color: #{value}"

    def boolean?(value) = value.is_a?(TrueClass) || value.is_a?(FalseClass)
    def link?(attribute) = attribute.end_with?("_link")
    def datetime?(attribute) = attribute.end_with?("_at")
    def time?(value) = value.is_a?(Time)
    def date?(attribute) = attribute.end_with?("_on")

    def model_id?(attribute, value)
      attribute.end_with?("_id") && value.is_a?(Numeric) && attribute.delete_suffix("_id").classify.safe_constantize
    end

    def json?(value)
      JSON.parse(value)
    rescue StandardError
      false
    end
  end
end
