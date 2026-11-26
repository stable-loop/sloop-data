# frozen_string_literal: true

class Data
  class ApplicationController < ApplicationController
    extend ActiveSupport::Concern
    include Data::DataHelper
    helper Data::ShowValueHelper
    include Pagy::Method

    before_action :authenticate_user!
    before_action :authorize_record_class, only: %i[index new create]
    before_action :set_records, only: %i[index]
    before_action :set_record, only: %i[show edit update destroy]
    helper_method :record_class, :bi_icon

    def record_class = controller_name.classify.constantize

    def bi_icon
      return "bi-table" unless self.class.const_defined?(:BI_ICON, false)

      self.class.const_get(:BI_ICON, false)
    end

    # GET /records
    def index
      render "data/index", locals: { list: @records }
    end

    # GET /records/1
    def show
      render "data/show", locals: { record: @record }
    end

    # GET /records/new
    def new
      render "data/new", locals: { record: record_class.new }
    end

    # GET /records/1/edit
    def edit
      render "data/edit", locals: { record: @record }
    end

    # POST /records
    def create
      @record = record_class.new(record_params)

      if @record.save
        redirect_to redirect_path, notice: t("actions.success.create", record: @record.class.model_name.human)
      else
        render "data/new", locals: { record: @record },
                           status: :unprocessable_content
      end
    end

    # PATCH/PUT /records/1
    def update
      if @record.update(record_params)
        redirect_to redirect_path, notice: t("actions.success.update", record: @record.class.model_name.human),
                                   status: :see_other
      else
        render "data/edit", locals: { record: @record }, status: :unprocessable_content
      end
    end

    # DELETE /records/1
    def destroy
      @record.destroy!
      redirect_to redirect_path, notice: t("actions.success.delete", record: @record.class.model_name.human),
                                 status: :see_other
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_records
      @records = policy_scope(record_class).order("id desc")
      @pagy, @records = pagy(@records)
    end

    def authorize_record_class
      authorize record_class
    end

    def set_record
      @record = record_class.find(params.expect(:id))
      authorize @record
    end

    def record_params
      filter = params.select { |_k, v| v.is_a?(Hash) || v.is_a?(ActionController::Parameters) }.keys.first
      params.expect(filter => policy(record_class).permitted_attributes)
    end

    def redirect_path
      path_to = action?("destroy") ? data_path_for(record_class, :index) : data_path_for(@record)
      @redirect_path ||= path_to
    end
  end
end
