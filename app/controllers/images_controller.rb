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
    binding.irb
    image = Image.find(params[:image_id])

    # Download the ActiveStorage file to a temp path
    input_path = Rails.root.join("tmp", "input_#{image.id}.jpg")
    output_path = Rails.root.join("tmp", "output_#{image.id}.jpg")

    File.open(input_path, 'wb') do |file|
      file.write(image.file.download)
    end

    # binding.irb 
    # Apply the requested process
    if params[:process_name] == "erode"
      erode_image(input_path, output_path)
    else
      dilate_image(input_path, output_path)
    end

    # Attach processed image back to model (replace or as new attachment)
    image.file.attach(
      io: File.open(output_path),
      filename: "processed_#{image.file.filename}",
      content_type: image.file.content_type
    )

    # Clean up temp files
    File.delete(input_path) if File.exist?(input_path)
    File.delete(output_path) if File.exist?(output_path)

    render json: { message: "Image processed successfully", status: 200 }
  end

  def erode_image(input_path, output_path)
    img = MiniMagick::Image.open(input_path)
    img.morphology "Erode", "Disk:1"
    img.write(output_path)
  end

  def dilate_image(input_path, output_path)
    img = MiniMagick::Image.open(input_path)
    img.morphology "Dilate", "Disk:1"
    img.write(output_path)
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
