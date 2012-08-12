require 'ruby_picasa'

class Author::PicasaController < Author::SpaceController
  before_filter :init_picasa
  
  def index
    @url = Picasa.authorization_url(authorize_author_albums_url) if @picasa.nil?
  end
  
  def destroy
    picasa_acc = Account.where(provider: "picasa", shard_id: @current_shard.id).first
    picasa_acc.destroy if picasa_acc
    redirect_to :author_picasa
  end
  
  private
  
  def init_picasa
    picasa_acc = Account.where(provider: "picasa", shard_id: @current_shard.id).first
    #find_by_provider_and_shard_id(:picasa, @current_shard)
    @picasa = picasa_acc.nil? ? nil : Picasa.new(picasa_acc.token)
  end
end
