class ProcessErodeJob < ApplicationJob
  queue_as :default

  def perform(image_id)
    sleep 10
    image = Image.find(image_id)

    input_path = Rails.root.join("tmp", "input_#{image.id}.jpg")
    output_path = Rails.root.join("tmp", "output_#{image.id}.jpg")

    # Download ActiveStorage file
    File.open(input_path, 'wb') do |file|
      file.write(image.file.download)
    end

    erode_image(input_path, output_path)

    # Attach processed image
    image.file.attach(
      io: File.open(output_path),
      filename: "processed_#{image.file.filename}",
      content_type: image.file.content_type
    )

    # Clean up temp files
    File.delete(input_path) if File.exist?(input_path)
    File.delete(output_path) if File.exist?(output_path)

    image.status = "ready"
    image.save!

    send_msg_to_channel(image.id)
  end


  def send_msg_to_channel(image_id)
    Rails.logger.info "[Cable] broadcasting..."
    ActionCable.server.broadcast("job_status", { message: "sucesso", image_id: image_id })
  end

  private

  def erode_image(input_path, output_path)
    img = MiniMagick::Image.open(input_path)
    img.morphology "Erode", "Disk:1"
    img.write(output_path)
  end
end
