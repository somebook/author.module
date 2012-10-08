module Author
  module Settings
    class AccountsController < ::Author::SpaceController

      def create
        account = Account.new(params[:account])
        account.user = @current_user
        account.shard = @current_shard
        account.save!

        redirect_to settings_path, notice: t("author.account.notice.create_success")
      end

      def destroy
        @account = Account.find(params[:id])
        @account.destroy

        redirect_to settings_path, notice: t("author.account.notice.delete_success")
      end

      def ga
        account = Account.find_by_id(params[:id])
        if params[:code]
          account.update_attribute(:additional, params[:code])
        end
        redirect_to root_path
      end

    end
  end
end