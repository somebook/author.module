class Author::TerminalsController < Author::SpaceController
  before_filter :set_shard_language
  def index
    @account = @shard_language.accounts.find(params[:account_id]) || not_found
    @terminals=@account.terminals
  end
  def new
    @form_legend = translate('author.terminal.form_legend.new')
    @terminal = Terminal.new
    @terminal.account= @shard_language.accounts.find(params[:account_id]) || not_found
    respond_to do |format|
      format.html { render :form }
      format.json { render json: @language }
    end
  end
  def create
    @terminal = Terminal.new(params[:terminal])
    @terminal.account= @shard_language.accounts.find(params[:account_id]) || not_found
    @form_legend = translate('author.terminal.form_legend.new')

    respond_to do |format|
      if @terminal.save
        format.html { redirect_to author_shard_language_account_terminals_path, notice: 'Terminal was successfully created.' }
        format.json { render json: @terminal, status: :created, location: @terminal }
      else
        format.html { render :form }
        format.json { render json: @terminal.errors, status: :unprocessable_entity }
      end
    end
  end
  def edit
    @terminal = Terminal.find_by_id(params[:id]) || not_found
    if(current_user.has_role_for_shard?(:master, @terminal.account.shard_language.shard))
      @form_legend = translate('author.terminal.form_legend.edit')
      respond_to do |format|
        format.html { render :form }
      end
    else
      not_found
    end
  end
  def destroy
    @terminal = Terminal.find_by_id(params[:id]) || not_found
    if(current_user.has_role_for_shard?(:master, @terminal.account.shard_language.shard))
      @terminal.destroy
      respond_to do |format|
        format.html { redirect_to author_shard_language_account_terminals_path, notice: 'Terminal was successfully deleted.' }
        format.json { head :ok }
      end
    else
      not_found
    end
  end
  def update
    @terminal = Terminal.find_by_id(params[:id]) || not_found
    if(current_user.has_role_for_shard?(:master, @terminal.account.shard_language.shard))
      @form_legend = translate('author.terminal.form_legend.edit')

      respond_to do |format|
        if @terminal.update_attributes(params[:terminal])
          format.html { redirect_to author_shard_language_account_terminals_path, notice: 'terminal was successfully updated.' }
          format.json { head :ok }
        else
          format.html { render :form }
          format.json { render json: @language.errors, status: :unprocessable_entity }
        end
      end
    else
      not_found
    end
  end
  private
  def set_shard_language
    @shard_language = ShardLanguage.find_by_id(params[:shard_language_id]) || not_found
  end
end
