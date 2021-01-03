require 'csv'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :update_basic_info, :attendance_csv]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :update_basic_info, :attendance_csv]
  before_action :admin_user, only: [:destroy, :update_basic_info, :index, :employees]
  before_action :set_one_month, only: [:show, :attendance_csv]
  before_action :not_admin_user, only: [:show]
  


  def index
    @users = User.paginate(page: params[:page]).search(params[:search])
    if params[:name].present?
       @user = User.find(params[:id])
    end
  end

  def new
    @user = User.new
  end

  def employees
    @users = User.all.includes(:attendances)
  end

  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    @superiors = superior_without_me
  end

  def create
    @user = User.new(user_params)
      if @user.save
        log_in @user
        flash[:success] = '新規作成に成功しました。'
        redirect_to @user
      else
        render :new
      end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = 'ユーザー情報を更新しました。'
      redirect_to @user
    else    
      render :edit
    end
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      @user_name = User.find(params[:id])
      flash[:danger] = "#{@user_name.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end


  def import
    if params[:file].blank?
      flash[:danger] = "CSVファイルを選択してください"
      redirect_to users_url
    else
      User.import(params[:file])
        flash[:success] = "ユーザー情報を追加/更新しました。"
        redirect_to users_url
    end
  end


  def attendance_csv
    respond_to do |format|
      format.html
        format.csv do |csv|
          send_attendances_csv(@attendances)
        end
    end
  end




  private

    def send_attendances_csv(attendances)
      csv_data = CSV.generate do |csv| 
        header = %W(日付 出社時間 退社時間)
         csv << header

         attendances.each do |attendance|
          if attendance.change_started_at.present? && attendance.change_finished_at.nil? && (attendance.change_status.blank? || attendance.change_status == "承認")
            values = [l(attendance.worked_on, format: :short), l(attendance.change_started_at, format: :time)]
          elsif attendance.change_started_at.present? && attendance.change_finished_at.present? && (attendance.change_status.blank? || attendance.change_status == "承認")
            values = [l(attendance.worked_on, format: :short), 
                      l(attendance.change_started_at, format: :time), l(attendance.change_finished_at, format: :time)]
            else
            values = [l(attendance.worked_on, format: :short)]
          end
            csv << values
         end
        end
        send_data(csv_data, filename: "勤怠情報.csv")
    end

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation)
    end

    def basic_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, 
                                   :basic_work_time, :designated_work_start_time, :password, :password_confirmation,
                                   :uid, :designated_work_end_time)
    end
end
