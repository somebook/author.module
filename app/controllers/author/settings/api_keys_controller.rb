module Author
  module Settings
    class ApiKeysController < ::Author::SpaceController

      # def index
      #   @api_keys = @current_shard.shard_languages.map{ |shard_language| shard_language.api_keys }.flatten
      # end

      def new
        @api_key = ApiKey.new
        @form_legend = t("author.api_key.form_legend.new")

        render :form
      end

      def edit
        @api_key = ApiKey.find(params[:id])
        not_found unless @current_shard.shard_languages.include? @api_key.shard_language
        @form_legend = t("author.api_key.form_legend.edit")

        render :form
      end

      def create
        @api_key = ApiKey.new(params[:api_key])

        if @api_key.save
          redirect_to settings_path, notice: t("author.api_key.notice.create_success")
        else
          render action: "new"
        end
      end

      def update
        @api_key = ApiKey.find(params[:id])
        not_found unless @current_shard.shard_languages.include? @api_key.shard_language

        if @api_key.update_attributes(params[:api_key])
          redirect_to settings_path, notice: t("author.api_key.notice.update_success")
        else
          render action: "edit"
        end
      end

      def destroy
        @api_key = ApiKey.find(params[:id])
        not_found unless @current_shard.shard_languages.include? @api_key.shard_language
        @api_key.destroy

        redirect_to settings_path
      end

    end
  end
end