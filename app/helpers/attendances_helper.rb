module AttendancesHelper

  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.change_started_at.nil?
      return '退勤' if attendance.change_started_at.present? && attendance.change_finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    false
  end

  # 勤怠編集用残業時間計算
  def working_times(start, finish, next_day)
    if next_day == "1"
      # format("%.2f", (24 - ((start - finish) / 60) / 60.0))
      hour = (24 - start.hour) + finish.hour
      min = finish.min - start.min
      @total_time = format("%.2f", (hour + min / 60.00))
    elsif
      # format("%.2f", (((finish - start) / 60) / 60.0))
      hour = finish.hour - start.hour
      min = finish.min - start.min
      @total_time = format("%.2f", (hour + min / 60.00))
    end
  end
  
  # 申請されている上長を抽出
  def overtime_superior_name(attendance)
    overtime_superipr = User.find_by(id: attendance.overtime_superior_id)
    overtime_superipr
  end

  # 申請されている上長を抽出
  def change_superior_name(attendance)
    change_superipr = User.find_by(id: attendance.change_superior_id)
    change_superipr
  end
  
  # 残業申請が自分にきているか
  def has_overtime_apply
    User.joins(:attendances).where(attendances: {overtime_superior_id: current_user.id}).where(attendances: {overtime_status: "申請中"})
  end

  #勤怠申請が自分にきていいるか
  def has_change_request
    User.joins(:attendances).where(attendances: {change_superior_id: current_user.id}).where(attendances: {change_status: "申請中"})
  end

  #勤怠申請が自分にきていいるか
  def has_one_month_apply
    User.joins(:attendances).where(attendances: {one_month_apply_superior_id: current_user.id}).where(attendances: {one_month_status: "申請中"})
  end

  def month_status(status)
    case status
    when "申請中"
      "へ申請中"
      
    when "否認"
      "から否認"

    when "承認"
      "から承認"
      
    else
      "未申請"
      
    end
  end


end