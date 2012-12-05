module Author
  module Settings
    class AccountsController < ::Author::SpaceController
      layout false, only: :terms

      def create
        @account = Account.new(params[:account])
        if params[:account][:provider] == "livejournal"
          user = LiveJournal::User.new(params[:account][:nickname], params[:account][:password])
          begin
            LiveJournal::Request::Login.new(user).run
            @account.name = @account.nickname
            @account.avatar = "http://l-stat.livejournal.com/img/ctxpopup-nopic.gif"
            error = false
          rescue
            error = true
          end
        end
        @account.user = @current_user
        @account.shard = @current_shard
        @account.save! unless error
        respond_to do |format|
          format.html { redirect_to settings_path, notice: t("author.account.notice.create_success") }
          format.js { flash[:error] = (error ? "Wrong login or password." : nil) }
        end
      end

      def destroy
        @account = Account.find(params[:id])
        @account.destroy
        respond_to do |format|
          format.html { redirect_to settings_path, notice: t("author.account.notice.delete_success") }
          format.js
        end
      end

      def ga
        account = Account.find_by_id(params[:id])
        if params[:code]
          account.update_attribute(:additional, params[:code])
        end
        redirect_to root_path
      end
      
      def terms
        @account = Account.find(params[:id])
      end

    end
  end
end