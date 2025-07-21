import consumer from "channels/consumer"

consumer.subscriptions.create("JobStatusChannel", {
  connected() {
    console.log("✅ Connected to JobStatusChannel")
  },

  disconnected() {
    console.log("❌ Disconnected from JobStatusChannel")
  },

  received(data) {
    $('[data-bg-id="' + data.image_id + '"]').addClass('bg-outdated')
                                             .removeClass('bg-warning')
                                             .text('Desatualizada');
  }
})
