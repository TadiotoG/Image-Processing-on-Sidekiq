require 'mini_magick'
class ImagesController < ApplicationController
  before_action :set_image, only: %i[ show edit update destroy ]

  # GET /images or /images.json
  def index
    @images = Image.all
  end

  # GET /images/1 or /images/1.json
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images or /images.json
  def create
    @image = Image.new(image_params)
    @image.file.attach(params[:image][:file])

    # binding.irb

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: "Image was successfully created." }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1 or /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to @image, notice: "Image was successfully updated." }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1 or /images/1.json
  def destroy
    @image.destroy!

    respond_to do |format|
      format.html { redirect_to images_path, status: :see_other, notice: "Image was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def process_img
    # ProcessImageJob.perform_in(1.minutes, params[:image_id], params[:process_name])
    img = Image.find(params[:image_id])

    if img.status != "ready"
      render json: { message: "Image is already being processed", status: 400 }
      return
    end

    img.status = "processing"
    img.save!

    # binding.irb

    time = 0

    if params[:process_name] == "dilated"
      ProcessDilateJob.perform_later(params[:image_id])
      # ProcessDilateJob.set(wait: time.seconds).perform_later(params[:image_id])
    elsif params[:process_name] == "erode"
      ProcessErodeJob.perform_later(params[:image_id])
    end

    render json: { message: "Processing started", status: 202, time: "#{time.to_s} segundos"}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def image_params
      params.expect(image: [ :name, :description ])
    end
end
