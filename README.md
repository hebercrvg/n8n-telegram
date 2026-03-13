# Telegram Weather Bot — n8n

Chatbot no Telegram que responde com a temperatura atual de uma cidade usando a API do OpenWeatherMap, orquestrado com n8n via Docker Compose.

## Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) e [Docker Compose](https://docs.docker.com/compose/install/) instalados
- Token de um bot Telegram (crie via [@BotFather](https://t.me/BotFather))
- Chave da API do [OpenWeatherMap](https://openweathermap.org/api) (plano gratuito é suficiente)

---

## Configuração das credenciais

1. Copie o arquivo de exemplo:

   ```bash
   cp .env.example .env
   ```

2. Preencha o arquivo `.env` com suas credenciais:
   ```env
   TELEGRAM_BOT_TOKEN=1234567890:AABBccDDeeFFggHHiiJJkkLLmmNNoopp
   OPENWEATHER_API_KEY=sua_chave_aqui
   ```

> **Importante:** nunca suba o arquivo `.env` para o repositório. Ele já está listado no `.gitignore`.

---

## Como executar

```bash
docker-compose up -d
```

Na primeira execução, o container irá automaticamente:

1. Criar a credencial Telegram no banco de dados do n8n usando o token do `.env`
2. Importar o workflow `workflow-telegram-chatbot.json`
3. Iniciar o n8n com o workflow já ativo

Acesse o painel n8n em: **http://localhost:5678**  
Login: `admin` / Senha: `admin`

---

## Como usar o chatbot

Com o container rodando, envie uma mensagem para o seu bot no Telegram com o nome de uma cidade:

```
São Paulo
Rio de Janeiro
Belo Horizonte,BR
```

**Resposta de sucesso:**

```
🌤️ A temperatura em Belo Horizonte é de 25°C.
💧 Umidade: 60%
🌬️ Vento: 3.5 m/s
🌥️ céu limpo
```

**Resposta de erro (cidade não encontrada):**

```
❌ Cidade não encontrada. Use o formato Cidade,UF (ex.: São Paulo,SP).
```

---

## Estrutura do Workflow

O workflow contém os seguintes nós em sequência:

| Nó                        | Tipo              | Descrição                                                                           |
| ------------------------- | ----------------- | ----------------------------------------------------------------------------------- |
| **Telegram Trigger**      | `telegramTrigger` | Recebe mensagens de texto do bot via long-polling                                   |
| **Set queue**             | `set`             | Captura o texto em `queue` (trim + lowercase + remove acentos) e o `chatId`         |
| **OpenWeather Request**   | `httpRequest`     | Consulta `api.openweathermap.org/data/2.5/weather` com `OPENWEATHER_API_KEY` do env |
| **IF Success**            | `if`              | Verifica se o campo `main` existe na resposta (cidade encontrada)                   |
| **Telegram Send Success** | `telegram`        | Envia a temperatura formatada ao usuário                                            |
| **Telegram Send Error**   | `telegram`        | Envia mensagem de erro ao usuário                                                   |

---

## Variáveis de ambiente esperadas

| Variável              | Descrição                           |
| --------------------- | ----------------------------------- |
| `TELEGRAM_BOT_TOKEN`  | Token do bot gerado pelo @BotFather |
| `OPENWEATHER_API_KEY` | Chave da API do OpenWeatherMap      |

---

## Como o setup automático de credenciais funciona

O `docker-entrypoint.sh` é executado antes de iniciar o n8n. Na primeira execução ele:

1. Gera um arquivo JSON de credencial usando `$TELEGRAM_BOT_TOKEN`
2. Importa a credencial no banco SQLite do n8n com `n8n import:credentials`
3. Importa o workflow com `n8n import:workflow`
4. Cria um arquivo de lock (`.n8n/.setup-done`) para não repetir nas próximas reinicializações

Adicionalmente, a variável `N8N_CREDENTIALS_OVERWRITE_DATA` no `docker-compose.yml` garante que o token seja sempre atualizado em tempo de execução, mesmo que o `.env` seja alterado após a primeira inicialização.

---

## Reset (recomeçar do zero)

Para apagar todos os dados do n8n e reimportar o workflow:

```bash
docker-compose down
rm -rf n8n/database.sqlite* n8n/.setup-done
docker-compose up -d
```
