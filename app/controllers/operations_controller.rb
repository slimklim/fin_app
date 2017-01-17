require 'date'

class OperationsController < ApplicationController
  before_action :signed_in_user, except: [:index, :filter, :charts]
  before_action :operation_by_current_user, only: [:show, :edit, :update, :delete]

  def index
    if signed_in?
      Operation.per_page = params[:per_page].to_i unless params[:per_page].blank?
      @balance = current_user[:balance].to_d
      @filterrific = initialize_filterrific(
        current_user.operations,
        params[:filterrific],
        select_options: { sorted_by: Operation.options_for_sorted_by,
                          with_credit: Operation.options_for_with_credit }
      ) or return
      @operations = @filterrific.find.page(params[:page])
      respond_to do |format|
        format.html
        format.js
      end
    else
      redirect_to welcome_path
    end
  rescue ActiveRecord::RecordNotFound => e
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
  end

  def filter
    index
    render 'index'
  end

  def charts
    @filtered_operations = Operation.where(id: params[:ids].split)
  end

  def new
    @operation = current_user.operations.build(date: Date.today, credit: false, tag: "Other")
  end

  def create
    @operation = current_user.operations.build(operation_params)
    if @operation.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  def edit
    @operation = current_user.operations.find(params[:id])
  end

  def update
    target_operation = current_user.operations.find(params[:id])
    if target_operation.update_attributes(operation_params)
      flash[:success] = "Record updated"
      redirect_to root_path
    else
      render 'edit'
    end
  end

  def show
    @operation = current_user.operations.find(params[:id])
  end

  def destroy
    target_operation = current_user.operations.find(params[:id])
    target_operation.destroy
    flash[:success] = "Operation deleted."
    redirect_to root_path
  end

  private

    def operation_params
      params.require(:operation).permit(:date, :value, :tag, :comment, :credit)
    end

    # Before filters

    def operation_by_current_user
      redirect_back_or(root_path) unless current_user[:id] == Operation.find(params[:id])[:user_id]
    end

end
