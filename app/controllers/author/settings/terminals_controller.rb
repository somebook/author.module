module Author
  module Settings
    class TerminalsController < ::Author::SpaceController      
      before_filter :set_streams
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
        @form_legend = t("author.terminal.form_legend.new")

        if @terminal.save
          respond_to do |format|
          format.html { redirect_to settings_path, notice: t("author.terminal.notice.create_success") }
          format.js
          end
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
        not_found unless im_master?(@terminal.account.shard)

        @terminal.destroy
        respond_to do |format|
          format.html { redirect_to settings_path, notice: t("author.terminal.notice.delete_success") }
          format.js
        end
      end

      def update
        @terminal = Terminal.find_by_id(params[:id]) || not_found
        not_found unless im_master?(@terminal.account.shard)

        @form_legend = t("author.terminal.form_legend.edit")

        if @terminal.update_attributes(params[:terminal])
          respond_to do |format|
            format.html { redirect_to settings_path, notice: t("author.terminal.notice.update_success") }
            format.js
          end
        else
          render :form
        end
      end
      
      def set_streams
        @streams = []
        @streams << :personal if can? :blog, Post.new(shard_id: @current_shard.id)
        @streams << :official if can? :news, Post.new(shard_id: @current_shard.id)
      end

    end
  end
end