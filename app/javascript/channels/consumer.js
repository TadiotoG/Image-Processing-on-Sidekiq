import { createConsumer } from "@rails/actioncable"

const consumer = createConsumer()

// Expor no window para debug
window.consumer = consumer

export default consumer
