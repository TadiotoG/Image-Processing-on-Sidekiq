class ProcessDilateJob < ApplicationJob
  queue_as :critical

  def perform(image_id)
    sleep 10
    image = Image.find(image_id)
    image.status = "ready"
    image.save!

    input_path = Rails.root.join("tmp", "input_#{image.id}.jpg")
    output_path = Rails.root.join("tmp", "output_#{image.id}.jpg")

    # Download ActiveStorage file
    File.open(input_path, 'wb') do |file|
      file.write(image.file.download)
    end

    dilate_image(input_path, output_path)

    # Attach processed image
    image.file.attach(
      io: File.open(output_path),
      filename: "processed_#{image.file.filename}",
      content_type: image.file.content_type
    )

    # Clean up temp files
    File.delete(input_path) if File.exist?(input_path)
    File.delete(output_path) if File.exist?(output_path)

    send_msg_to_channel(image.id)
  end


  def send_msg_to_channel(image_id)
    Rails.logger.info "[Cable] broadcasting..."
    ActionCable.server.broadcast("job_status", { message: "sucesso", image_id: image_id })
  end

  def dilate_image(input_path, output_path)
    img = MiniMagick::Image.open(input_path)
    img.morphology "Dilate", "Disk:1"
    img.write(output_path)
  end
end
