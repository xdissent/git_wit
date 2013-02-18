class PublicKeysController < ApplicationController
  load_and_authorize_resource

  # GET /public_keys
  # GET /public_keys.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @public_keys }
    end
  end

  # GET /public_keys/1
  # GET /public_keys/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @public_key }
    end
  end

  # GET /public_keys/new
  # GET /public_keys/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @public_key }
    end
  end

  # POST /public_keys
  # POST /public_keys.json
  def create
    @public_key.user = current_user
    respond_to do |format|
      if @public_key.save
        # PublicKey.regenerate_authorized_keys
        GitWit.add_authorized_key(current_user.username, @public_key.raw_content)

        format.html { redirect_to @public_key, notice: 'Public key was successfully created.' }
        format.json { render json: @public_key, status: :created, location: @public_key }
      else
        format.html { render action: "new" }
        format.json { render json: @public_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /public_keys/1
  # DELETE /public_keys/1.json
  def destroy
    @public_key.destroy
    # PublicKey.regenerate_authorized_keys
    GitWit.remove_authorized_key(@public_key.raw_content)

    respond_to do |format|
      format.html { redirect_to public_keys_url }
      format.json { head :no_content }
    end
  end
end
