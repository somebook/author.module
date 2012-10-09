module Author
  module Settings
    class AmazonSettingsController < ::Author::SpaceController
      def create
        amazon = AmazonSetting.new(params[:amazon_setting])
        amazon.shard = @current_shard
        if amazon.save
          redirect_to settings_path, notice: t("author.amazon_settings.notice.create_success")
        else
          redirect_to settings_path, error: t("author.amazon_settings.error.create_fails")
        end
      end
      
      def destroy
        @amazon_setting = @current_shard.amazon_setting
        @amazon_setting.destroy if @amazon_setting

        redirect_to settings_path, notice: t("author.amazon_settings.notice.delete_success")
      end
      
      def update
        @amazon_setting = @current_shard.amazon_setting
        
        @amazon_setting.update_attributes(params[:amazon_setting])

        redirect_to settings_path, notice: t("author.amazon_settings.notice.update_success")
      end
    end
  end
end