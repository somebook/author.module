module Author
  module Settings
    class TerminalsController < ::Author::SpaceController
      before_filter :set_shard_language

      def index
        @account = @shard_language.accounts.find(params[:account_id]) || not_found
        @terminals = @account.terminals
      end

      def new
        @terminal = Terminal.new
        @terminal.account = @shard_language.accounts.find(params[:account_id]) || not_found
        @form_legend = t("author.terminal.form_legend.new")

        render :form
      end

      def create
        @terminal = Terminal.new(params[:terminal])
        @terminal.account = @shard_language.accounts.find(params[:account_id]) || not_found
        @form_legend = t("author.terminal.form_legend.new")

        if @terminal.save
          redirect_to settings_shard_language_account_terminals_path, notice: t("author.terminal.notice.create_success")
        else
          render :form
        end
      end

      def edit
        @terminal = Terminal.find_by_id(params[:id]) || not_found
        not_found unless im_master?(@terminal.account.shard_language.shard)

        @form_legend = t("author.terminal.form_legend.edit")
        render :form
      end

      def destroy
        @terminal = Terminal.find_by_id(params[:id]) || not_found
        not_found unless im_master?(@terminal.account.shard_language.shard)

        @terminal.destroy
        redirect_to settings_shard_language_account_terminals_path, notice: t("author.terminal.notice.delete_success")
      end

      def update
        @terminal = Terminal.find_by_id(params[:id]) || not_found
        not_found unless im_master?(@terminal.account.shard_language.shard)

        @form_legend = t("author.terminal.form_legend.edit")

        if @terminal.update_attributes(params[:terminal])
          redirect_to settings_shard_language_account_terminals_path, notice: t("author.terminal.notice.update_success")
        else
          render :form
        end
      end

    private

      def set_shard_language
        @shard_language = ShardLanguage.find_by_id(params[:shard_language_id]) || not_found
      end

    end
  end
end