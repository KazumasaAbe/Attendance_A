class AttendancesController < ApplicationController
  

  before_action :set_user, only: [:edit_one_month, :over_time_edit_info, :over_time_update_info,
                                  :receve_overtime_work_apply, :confirmation_overtime_work_apply,
                                  :update_one_month, :receve_change_one_month, :change_request_one_month,
                                  :confirmation_change_one_month, :request_one_month, :receve_one_month,
                                  :confirmation_one_month, :attendances_log]

  before_action :logged_in_user, only: [:update, :edit_one_month, :over_time_edit_info,
                                        :over_time_update_info, :recive_overtime_work_apply,
                                        :receve_change_one_month, :change_request_one_month,
                                        :confirmation_change_one_month, :request_one_month, :receve_one_month,
                                        :confirmation_one_month, :attendances_log]

  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month, :receve_change_one_month]

  before_action :set_one_month, only: [:edit_one_month, :over_time_edit_info, :recive_overtime_work_apply,
                                       :confirmation_overtime_work_apply, :receve_change_one_month,
                                       :confirmation_change_one_month, :change_request_one_month,
                                       :receve_one_month, :attendances_log]
  
  before_action :not_admin_user, only: [:edit_one_month, :over_time_edit_info, :recive_overtime_work_apply,
                                        :confirmation_overtime_work_apply, :receve_change_one_month,
                                        :confirmation_change_one_month, :change_request_one_month,
                                        :receve_one_month, :attendances_log]


  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  INVALID_MSG = "無効な入力データがあった為、更新をキャンセルしました。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0),
                                       change_started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0),
                                       change_finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end


  # 勤怠編集関連----------------------------------------

  # 勤怠編集ページ
  def edit_one_month
    @superiors = superior_without_me
  end

  # 勤怠申請
  def change_request_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      if one_month_valid?
          attendances_params.each do |id, item|
            attendance = Attendance.find(id)
            if item[:change_superior_id].present?
              attendance.update_attributes(change_superior_name: User.find(item[:change_superior_id]).name)
              attendance.update_attributes!(item)
            end
            end
            flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
            redirect_to user_url(date: params[:date])
      else
        flash[:danger] = "#{INVALID_MSG}<br>#{@msg}"
        redirect_to user_url(date: params[:date])
      end
    end

  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end


  # 勤怠申請お知らせページ
  def receve_change_one_month
    @users = User.joins(:attendances).where(attendances: {change_superior_id: current_user.id}).where(attendances: {change_status: "申請中"}).distinct
  end

  # 勤怠申請承認・否認
  def confirmation_change_one_month
    change_one_month_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:change_check] == "1" && (item[:change_status] == "承認" || item[:change_status] == "否認")
        attendance.update_attributes(item)
      end
    end
   flash[:success] = "勤怠申請の決済を更新しました。"
   redirect_to @user
  end

  #---------------------------------------------------





  # 残業申請関連----------------------------------------

  # 残業申請ページ
  def over_time_edit_info
    @superiors = superior_without_me
  end

  # 残業申請
  def over_time_update_info
    overtime_work_apply_params.each do |id, item|
      if selected_overtime_superior?
        attendance = Attendance.find(id)
        attendance.update_attributes(item)#unless time_select_invalid?(item)
        if attendance.next_day_check == "1"
          next_day_times(@user.designated_work_end_time, attendance.overtime_end_plan)
        else
          overworking_times(@user.designated_work_end_time, attendance.overtime_end_plan)
        end
        attendance.update_attributes(overtime_hour: @total_times, overtime_superior_name: User.find(item[:overtime_superior_id]).name)
        flash[:success] = "#{attendance.overtime_superior_name}に残業申請を提出しました。"
        redirect_to @user
      else
        msg_a = "申請先上長を選択してください。" if item[:overtime_superior_id].blank?
        msg_b = "業務処理内容を入力してください。" if item[:overtime_detail].blank?
        msg_c = "終了予定時間を入力してください。" if item[:overtime_end_plan].blank?
        msg_d = "指定勤務終了時間より前の時間は選択できません。" if item[:overtime_end_plan] < @user.designated_work_end_time.strftime("%R") && item[:next_day_check] == "0" && item[:overtime_end_plan].present?
        msg_e = "指定勤務開始時間より後の時間は選択できません。" if item[:overtime_end_plan] > @user.designated_work_start_time.strftime("%R") && item[:next_day_check] == "1" && item[:overtime_end_plan].present?
        flash[:danger] = "#{msg_a}#{msg_b}#{msg_c}#{msg_d}#{msg_e}"
        redirect_back(fallback_location: root_path)
      end
    end
  end

  # 残業申請お知らせページ
  def receve_overtime_work_apply
    @users = User.joins(:attendances).where(attendances: {overtime_superior_id: current_user.id}).where(attendances: {overtime_status: "申請中"}).distinct
  end

  # 残業申請承認・否認
  def confirmation_overtime_work_apply
    confirmation_overtime_work_apply_params.each do |id, item|
        attendance = Attendance.find(id)
            attendance.update_attributes!(item) if item[:overtime_check] == "1" && (item[:overtime_status] == "承認" || item[:overtime_status] == "否認")
        end
        flash[:success] = "残業申請の決済を行いました。"
        redirect_to @user
          
        rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
          flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
          redirect_to @user
  end
  # -------------------------------------------------------


  # １ヶ月勤怠申請関連----------------------------------------

  # 1ヶ月勤怠申請お知らせページ
  def receve_one_month
    @users = User.joins(:attendances).where(attendances: {one_month_apply_superior_id: current_user.id}).where(attendances: {one_month_status: "申請中"}).distinct
  
  end

  # 1ヶ月勤怠申請
  def request_one_month
    one_month_apply_params.each do |id, item|

      attendance = Attendance.find(id)
      if item[:one_month_apply_superior_id].present?
        attendance.update_attributes(one_month_superior_name: User.find(item[:one_month_apply_superior_id]).name)
        attendance.update_attributes(item)
        flash[:success] = "1ヶ月分の勤怠を#{attendance.one_month_superior_name}へ申請しました。"
      else
        flash[:danger] = "所属長を選択してください"
      end
    end
    redirect_to @user
  end

  # 1ヶ月勤怠申請承認・否認
  def confirmation_one_month
    confirmation_one_month_apply_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:one_month_check] == "1" && (item[:one_month_status] == "承認" || item[:one_month_status] == "否認")
        attendance.update_attributes(item)
        if attendance.one_month_status == "否認"
           attendance.update_attributes(one_month_check: "0", one_month_approval: 1)
        end
      end
    end
    flash[:success] = "月別勤怠の決済を更新しました。"
    redirect_to @user
  end

  # -------------------------------------------------------

  def attendances_log

    if Attendance.where(user_id: @user.id).where.not(calendar_day: nil).present?
      @start_year =  Attendance.where(user_id: @user.id).minimum(:calendar_day).year
      @end_year = Attendance.where(user_id: @user.id).maximum(:calendar_day).year
    end


    @logs =
    if params[:search].blank?
      Attendance.where(user_id: @user.id).where(worked_on: @first_day..@last_day).where(change_approval: 3)
    else
        search_years = ActiveSupport::HashWithIndifferentAccess.new(worked_on: params[:search]["worked_on(1i)"])
        search_months = ActiveSupport::HashWithIndifferentAccess.new(worked_on: params[:search]["worked_on(2i)"])
        @search_year = search_years[:worked_on]
        @search_month = search_months[:worked_on]
        Attendance.where(user_id: @user.id).search(params[:search]["worked_on(1i)"])
                                           .search(params[:search]["worked_on(2i)"])
                                           .where(change_approval: 3)
                                           .order(worked_on: "ASC")
        
      end
    end












  private

  # 残業申請情報
  def overtime_work_apply_params
    params.require(:user).permit(attendances: [:overtime_end_plan, :next_day_check, :overtime_detail, :overtime_superior_id,
                                 :overtime_hour, :overtime_status, :overtime_approval, :overtime_check ])[:attendances]
  end
  
  # 残業承認情報
  def confirmation_overtime_work_apply_params
    params.require(:user).permit(attendances: [:overtime_status, :overtime_check, :overtime_approval])[:attendances]
  end

  # 1ヶ月分の勤怠情報
  def attendances_params
    params.require(:user).permit(attendances: [:change_started_at, :change_finished_at, :change_note, 
                                               :change_superior_id, :change_status, :change_approval, :calendar_day, :change_next_day_check])[:attendances]
  end

  # 勤怠承認
  def change_one_month_params
    params.require(:user).permit(attendances: [:change_check, :change_status, :change_approval, :change_date])[:attendances]
  end

  # 月別勤怠情報
  def one_month_apply_params
    params.require(:user).permit(attendances: [:one_month_apply_superior_id, :one_month_approval, :one_month_status])[:attendances]
  end

  # 月別勤怠承認情報
  def confirmation_one_month_apply_params
    params.require(:user).permit(attendances: [:one_month_apply_superior_id, :one_month_approval, :one_month_status, :one_month_check])[:attendances]
  end

  # 管理者又は、ログイン者
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      falsh[:danger] = "権限がありません。"
      redirect_to(root_url)
    end
  end

  # 残業申請先の上長の選択されているか？業務処理内容が入力されているか？
  def selected_overtime_superior?
    superior = true
    overtime_work_apply_params.each do |id, item|
      if item[:overtime_superior_id].blank? || item[:overtime_detail].blank? || item[:overtime_end_plan].blank?
        superior = false
      elsif item[:overtime_superior_id].present? && item[:overtime_detail].present? || item[:overtime_end_plan].present?
      
        if item[:overtime_end_plan] > @user.designated_work_end_time.strftime("%R") && item[:next_day_check] == "0"
        superior = true
        elsif item[:overtime_end_plan] < @user.designated_work_start_time.strftime("%R") && item[:next_day_check] == "1"
        superior = true
        else
        superior = false
        end
        break
      end
    end
    superior
  end

  # 翌日チェック有残業時間計算
  def next_day_times(basic, finish)
    hour = (24 - basic.hour) + finish.hour
    min = finish.min + basic.min
    @total_times = hour + min /60.00
  end

  # 翌日チェック無残業時間計算
  def overworking_times(basic, finish)
    hour = finish.hour - basic.hour
    min = finish.min - basic.min
    @total_times = hour + min /60.00
  end

  # 勤怠編集データチェック
  def one_month_valid?
    attendance = true
    attendances_params.each do |id, item|

      if item[:change_superior_id].blank?
        next

      elsif item[:change_note].blank?
        attendance = false
        @msg = "備考を入力してください。"
        break

      elsif item[:change_started_at].blank?
        attendance = false
        break

      elsif item[:change_finished_at].blank?
        attendance = false
        break

      elsif item[:change_next_day_check] == "0" && item[:change_started_at] > item[:change_finished_at]
        attendance = false
        break

      elsif item[:change_next_day_check] == "1" && item[:change_started_at] < item[:change_finished_at]
        attendance = false
        break

      end
    end
    return attendance
  end

  end