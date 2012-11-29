module Author
  module Settings
    class ShardLanguagesController < ::Author::SpaceController
      load_and_authorize_resource

      def index
        @languages = @current_shard.shard_languages
      end
    end
  end
end
