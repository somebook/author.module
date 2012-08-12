class Author::AccountsController < Author::SpaceController
  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    redirect_to shard_languages_path, notice: 'Account was successfully removed.'
  end

  def create
    account = Account.new(params[:account])
    account.user = @current_user
    account.shard = @current_shard
    account.save!
    respond_to do |format|
      format.html { redirect_to shard_languages_path, notice: 'Account was successfully created.' }
      format.json { head :ok }
    end
  end

  def ga
    account = Account.find_by_id(params[:id])
    if params[:code]
      account.update_attribute(:additional, params[:code])
    end
    redirect_to root_path
  end

end
