module Author
  module Settings
    class ShardLanguagesController < ::Author::SpaceController
      load_and_authorize_resource

      def index
        @languages = @current_shard.shard_languages
      end

      def link_service
        language = @current_shard.shard_languages.find(params[:shard_language_id])
        cookies[:language] = language.id
        cookies[:stream] = params[:stream]
        redirect_to main_app.user_omniauth_authorize_path(params[:code].downcase.to_sym)
      end

    end
  end
end