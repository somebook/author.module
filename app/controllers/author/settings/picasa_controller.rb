require "ruby_picasa"

module Author
  module Settings
    class PicasaController < ::Author::SpaceController

      # def index
      #   @url = Picasa.authorization_url(authorize_albums_url) if @picasa.nil?
      # end

      def destroy
        picasa_acc = Account.where(provider: "picasa", shard_id: @current_shard.id).first
        picasa_acc.destroy if picasa_acc

        redirect_to settings_path
      end
    end
  end
end
