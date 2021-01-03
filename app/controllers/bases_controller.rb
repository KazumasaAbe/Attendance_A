class BasesController < ApplicationController

  before_action :set_user, only: [:index, :update, :destroy, :create]
  before_action :logged_in_user, only: [:index, :update, :destroy, :create]
  before_action :admin_user, only: [:index, :update, :destroy, :create]
  before_action :set_base, only: [:update, :destroy]



  def index
    @bases = Base.all
    @base = Base.new
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = '拠点情報を追加しました。'
      redirect_to bases_url
    else
      flash[:danger] = "拠点登録に失敗しました。<br>
      入力エラーが#{@base.errors.count}件あります。<br>" + @base.errors.full_messages.join("<br>")
      redirect_to bases_url
    end
  end

  def update
      if @base.update_attributes(base_params)
         flash[:success] ="拠点情報を更新しました"
         redirect_to bases_url
    else
      flash[:danger] = "拠点登録に失敗しました。<br>
      入力エラーが#{@base.errors.count}件あります。<br>" + @base.errors.full_messages.join("<br>")
      redirect_to bases_url
  end
end

  def destroy
    @base.destroy
    flash[:success] = "拠点情報を削除しました。"
    redirect_to bases_url
  end

  private

  def base_params
    params.require(:base).permit(:base_number, :base_name, :base_type)
  end

  def set_base
    @base = Base.find(params[:id])
  end


end
