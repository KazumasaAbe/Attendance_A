Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'
  get '/employees', to: 'users#employees'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users do
    member do
      get 'attendance_csv'
      get 'edit_basic_info'
      patch 'update_basic_info'

      #残業申請関連
      get 'attendances/over_time_edit_info'               #残業申請ページ
      patch 'attendances/over_time_update_info'           #残業申請patch
      get 'attendances/receve_overtime_work_apply'        #残業申請確認ページ
      patch 'attendances/confirmation_overtime_work_apply'#残業申請承認/否認等patch

      #勤怠申請関連
      get 'attendances/edit_one_month'                    #勤怠申請ページ
      patch 'attendances/change_request_one_month'        #勤怠申請patch
      get 'attendances/receve_change_one_month'           #勤怠申請確認ページ
      patch 'attendances/confirmation_change_one_month'   #勤怠申請承認/否認等patch

      #1ヶ月勤怠申請
      patch 'attendances/request_one_month'                #1ヶ月勤怠申請patch
      get 'attendances/receve_one_month'                   #1ヶ月勤怠申請確認ページ
      patch 'attendances/confirmation_one_month'           #1ヶ月勤怠申請承認/否認等patch

      get 'attendances/attendances_log'

      resources :bases

    end
        resources :attendances, only: :update
  end


  resources :users do
    collection {post :import}
  end
end
