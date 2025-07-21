# 🖼️ Processamento de Imagens com Rails e Sidekiq

## 📦 Especificações Técnicas
- **Ruby**: 3.2.4
- **Rails**: 8.0.2
- **Sidekiq**: 8.0.5
- **Redis**: 7.0.15
- **Mini Magick**: 5.3.0

## 📖 Sobre a Aplicação
Aplicação desenvolvida para demonstrar o processamento assíncrono de imagens utilizando:
- Técnicas de processamento de imagem: erosão e dilatação
- Sidekiq para background jobs
- Redis como backend para filas

> 🟣 **Observações:**
> - A versão inicial foi implementada sem workers assíncronos
> - O desenvolvimento foi realizado no VSCode utilizando WSL2
> - O sistema foi testado em ambiente Linux (Ubuntu 22.04)




## ⚙️ Configuração do Ambiente

### 1️⃣ Dependências
Adicione ao `Gemfile`:

```ruby
gem 'mini_magick', '5.3.0'
gem 'sidekiq', '8.0.5'
gem 'redis', '4.8.1'
```

Depois execute `bundle install`

### 2️⃣ Configure o Sidekiq:

Em `application.rb` adicione `config.active_job.queue_adapter = :sidekiq`:

> 🟣 Serve para o Rails saber que tem que enfileirar os processos ao encontrar um worker

```ruby
...
module ImgProcessing
  class Application < Rails::Application
    config.load_defaults 8.0
    config.active_job.queue_adapter = :sidekiq
  ...
```

Crie o arquivo `config/sidekiq.yml` para definir as filas e o número de threads:

```yaml
:concurrency: 1

:queues:
  - [critical, 2]
  - [default, 1]

:timeout: 25
:logfile: ./log/sidekiq.log

:redis:
  :url: redis://localhost:6379/0
  :namespace: sidekiq
```
> 🟣 Redis já é configurado aqui

Configure as rotas para ao Sidekiq encontrar o Redis:
`sidekiq.rb`:
```ruby
return unless defined?(Sidekiq)

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end
```

> 🟣 Na teoria não seria necessário configurar os dois arquivos acima, apenas o o **yml**, porém foi desta maneira que fiz e funcionou 👍

### 3️⃣ Configure as rotas para acessar o painel Sidekiq:

```ruby
require 'sidekiq/web'
mount Sidekiq::Web => '/sidekiq'
```

### 4️⃣ Crie o Worker Assíncrono:

- `rails generate job ProcessErodeJob`

- Em `process_erode_job.rb`:
```ruby
class ProcessErodeJob < ApplicationJob
  queue_as :default # Define em qual fila sera colocado

  def perform(image_id)
    img = Image.find(image_id)
    process_img(img)
    ...
  end
end
```

### 5️⃣ Chame o Worker no controller que deseja utilizar

```ruby
class ImagesController < ApplicationController
  before_action :set_image, only: %i[ show edit update destroy ]

  ...

  def process_img
    ProcessErodeJob.perform_later(params[:image_id])
    
    render json: { message: "Processing started", status: 202}
  end
end
```

### 6️⃣ Como executar a aplicação 🚀

1. **Inicie o Redis** (se necessário):  
 ```bash
 redis-server
 ```

> 🟣 No meu caso executei a aplicação no VSCode utilizando WSL2, então por algum motivo meu redis já estava rodando, logo não era necessário inicia-lo

> 🟣 Para verificar se o redis está rodando execute: `redis-cli ping`, deve retornar **PONG**

2. **Inicie o Sidekiq em outro terminal:**
 ```bash
   bundle exec sidekiq
   ```

3. **Inicie o servidor Rails:**
 ```bash
   rails server
 ```
---

## 🎉✨ **Parabéns!** Você conseguiu criar uma aplicação assíncrona 🤘🚀

- Agora seus jobs rodam sem bloquear o servidor. 🖥️📦⚡

# ActionCable 🔌

## 1️⃣ Crie o arquivo  `config/cable.yml`:
```yml
development:
  adapter: redis # Sem isso o Rails usa o adaptador async, que não funciona com Sidekiq
  url: redis://localhost:6379/1 # Utiliza o /1 pois é outro banco lógico dentro do mesmo Redis
```

## 2️⃣ Carregar os canais no browser
Adicione `import "channels"` no `application.js`

## 3️⃣ Crie o `app/javascript/channels/consumer.js`:
```js
import { createConsumer } from "@rails/actioncable"

const consumer = createConsumer()

// Expor no window para debug
window.consumer = consumer

export default consumer
```

## 4️⃣ Crie `app/javascript/channels/index.js`:
`import "channels/job_status_channel"`

> 🟣 Serve para carregar o `job_status_channel` no cliente

## 5️⃣ Crie o módulo com o comando `rails generate channel JobStatus`:

Ele automaticamente vai gerar dois arquivos:

- `job_status_channel.js` onde você vai configurar o que acontece quando é conectado, desconectado e recebe dados:
```js
import consumer from "channels/consumer"

consumer.subscriptions.create("JobStatusChannel", {
  connected() {
    console.log("✅ Connected to JobStatusChannel")
  },

  disconnected() {
    console.log("❌ Disconnected from JobStatusChannel")
  },

  received(data) {
    // Lógica do que voce quer fazer assim que receber a mensagem
  }
})
```

- `job_status_channel.rb` onde você vai se inscrever em um canal:
```ruby
class JobStatusChannel < ApplicationCable::Channel
  def subscribed
    stream_from "job_status"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
```

> 🟣 Quando o arquivo código em js se inscrever no JobStatusChannel, ele vai "escutar" do canal "job_status" como é definido no rb

## 6️⃣ Envie a mensagem do back-end para o front
```ruby
class ProcessDilateJob < ApplicationJob
  queue_as :critical

  def perform(image_id)
    ...

    send_msg_to_channel(image.id)
  end

  def send_msg_to_channel(image_id)
    ActionCable.server.broadcast("job_status", { message: "sucesso", image_id: image_id })
  end
end
```

```yml
:verbose: false
:pidfile: tmp/pids/sidekiq.pid
:max_retries: 2
:network_timeout: 2
:concurrency: <%= ENV["SIDEKIQ_CONCURRENT"] || 1 %>
:logfile: ./log/sidekiq_development.log
:queues:
  - [ document_signatures, 2 ]
  - [ sante_whats, 2 ]
  - [ critical, 2 ]
  - [ report, 1 ]
  - [ default, 1 ]
  - [ audits, 1 ]
  - [ tracking, 1 ]
:timeout: 20
```
