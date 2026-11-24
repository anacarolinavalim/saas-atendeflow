# ConectaFlow

### CRM, campanhas e atendimento. Tudo conectado ao WhatsApp.

**ConectaFlow** é uma plataforma SaaS multi-tenant desenvolvida para centralizar o relacionamento com clientes, organizar leads, gerenciar campanhas e automatizar processos de atendimento utilizando a **WhatsApp Business Platform — Meta Cloud API**.

Uma solução para empresas que desejam profissionalizar sua comunicação, acompanhar oportunidades comerciais e manter todo o histórico de relacionamento em um único lugar.

---

## Visão geral

O ConectaFlow reúne ferramentas de CRM, marketing e atendimento em uma única plataforma, permitindo que cada empresa gerencie sua própria operação de forma independente e segura.

**Principais benefícios:**

Para uma instalação rápida, copie `.env.example` para `.env`, ajuste o MariaDB e importe `database/schema.sql`. Para apresentar o produto com dados de exemplo, importe também `database/demo_data.sql`.

- Centralização dos contatos e históricos de atendimento.
- Organização de leads por tags, grupos e status.
- Campanhas segmentadas e agendadas.
- Acompanhamento de mensagens e resultados.
- Gestão de conversas e atribuição de atendentes.
- Automações comerciais e funis de relacionamento.
- Controle de planos, assinaturas e utilização.

---

## Funcionalidades

### 01. Dashboard inteligente

Acompanhe os principais indicadores da operação em uma visão centralizada.

- Total de contatos cadastrados.
- Campanhas e mensagens enviadas.
- Indicadores de entrega e falhas.
- Desempenho das campanhas.
- Capacidade e utilização da conta.
- Gráficos e métricas de acompanhamento.

### 02. CRM de contatos

Gerencie seus clientes e potenciais compradores de maneira organizada.

- Cadastro e edição de contatos.
- Tags e grupos personalizados.
- Classificação por status.
- Histórico de interações.
- Registro de consentimento.
- Lista de supressão para contatos que não devem receber campanhas.

### 03. Campanhas de WhatsApp

Crie campanhas direcionadas utilizando a integração oficial da Meta.

- Criação e gerenciamento de campanhas.
- Segmentação por tags, grupos e status.
- Prévia antes do envio.
- Agendamento de campanhas.
- Acompanhamento do progresso.
- Controle de mensagens pendentes, enviadas e com falha.
- Processamento por fila persistente.

### 04. Atendimento e caixa de entrada

Organize as conversas e facilite o acompanhamento dos clientes.

- Caixa de entrada centralizada.
- Histórico de mensagens.
- Organização de conversas.
- Atribuição de atendentes.
- Registro de eventos e atualizações.
- Integração com webhooks da Meta.

### 05. Automações e funis

Estruture processos comerciais para acompanhar os contatos durante sua jornada.

- Funis de relacionamento.
- Etapas personalizadas.
- Movimentação de contatos entre etapas.
- Persistência das informações.
- Organização do processo comercial.

### 06. Gestão SaaS e administração

Estrutura preparada para oferecer a plataforma como serviço.

- Cadastro de empresas independentes.
- Planos e limites de utilização.
- Assinaturas.
- Registro de cobranças.
- Controle de consumo.
- Painel administrativo.
- Gestão de contas e usuários.

---

## Arquitetura e tecnologias

| Tecnologia | Aplicação |
|---|---|
| PHP 8.2+ | Backend e regras de negócio |
| MySQL 8.0+ | Banco de dados relacional |
| PDO | Acesso seguro ao banco |
| JavaScript | Interatividade da interface |
| HTML5 / CSS3 | Estrutura e apresentação |
| Meta Graph API | Integração oficial com WhatsApp |
| Webhooks | Recebimento de eventos |
| Cron / Worker | Processamento e agendamento |

**Arquitetura:** PHP puro, sem dependência obrigatória de frameworks, com separação de responsabilidades entre autenticação, infraestrutura e domínio.

---

## Segurança e isolamento

A plataforma foi estruturada considerando a operação de múltiplas empresas em um mesmo ambiente.

- Isolamento de dados por empresa (multi-tenant).
- Autenticação com `password_hash`.
- Sessões com configurações de segurança.
- Proteção CSRF.
- Consultas parametrizadas com PDO.
- Criptografia de tokens de integração.
- Verificação de assinatura dos webhooks.
- Processamento idempotente de eventos.
- Controle de concorrência e retentativas na fila.

### Integração oficial com a Meta

Cada empresa utiliza suas próprias credenciais de integração:

- WABA ID.
- Phone Number ID.
- Access Token.
- Webhook de recebimento.
- Chave de verificação e assinatura.

O ConectaFlow utiliza a API oficial da Meta, respeitando as políticas de mensagens, templates aprovados, categorias, janelas de atendimento e limites aplicáveis à conta.

**Não utiliza automação de WhatsApp Web, rotação de números ou mecanismos de contorno dos limites da plataforma.**

---

## Estrutura do projeto

```text
ConectaFlow/
│
├── public/
│   ├── index.php
│   ├── webhook.php
│   └── assets/
│
├── src/
│   ├── Auth/
│   ├── Database/
│   ├── Meta/
│   └── Domain/
│
├── bin/
│   ├── worker.php
│   ├── cron.php
│   └── hash-password.php
│
├── database/
│   └── schema.sql
│
├── .env.example
└── README.md
```

---

## Instalação

### Pré-requisitos

- PHP 8.2 ou superior.
- MySQL 8.0 ou superior.
- Extensões PHP: `pdo_mysql`, `curl`, `json`, `mbstring` e `openssl`.
- Apache, Nginx ou PHP-FPM.
- Composer opcional.
- Cron ou processo worker contínuo.

### 1. Clonar o projeto

```bash
git clone URL_DO_REPOSITORIO
cd ConectaFlow
```

### 2. Configurar ambiente

Copie o arquivo de exemplo:

```bash
cp .env.example .env
```

Configure as credenciais do banco de dados e as demais variáveis necessárias.

### 3. Criar o banco

Crie o banco MySQL e importe o esquema:

```bash
mysql -u root -p -e "CREATE DATABASE conectaflow CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

```bash
mysql -u root -p conectaflow < database/schema.sql
```

### 4. Configurar o usuário inicial

Gere um novo hash de senha:

```bash
php bin/hash-password.php
```

Atualize o hash correspondente ao usuário inicial na tabela `users`.

### 5. Configurar o servidor

Configure o document root apontando exclusivamente para:

```text
ConectaFlow/public/
```

Não exponha diretamente os diretórios `src`, `bin`, `database` ou os arquivos de configuração.

### 6. Iniciar o processamento

Execute o worker:

```bash
php bin/worker.php
```

Configure o cron para executar o agendador a cada minuto:

```cron
* * * * * cd /caminho/ConectaFlow && php bin/cron.php
```

### 7. Configurar a Meta Cloud API

Configure o webhook no painel de desenvolvedores da Meta:

```text
https://SEU_DOMINIO/webhook.php
```

Informe as credenciais e os tokens necessários no ambiente da aplicação.

---

## Configurações de produção

Antes de disponibilizar o sistema:

- Defina `APP_ENV=production`.
- Configure uma `APP_KEY` forte.
- Utilize HTTPS.
- Proteja os tokens de integração.
- Configure backups automáticos.
- Restrinja os privilégios do usuário MySQL.
- Configure logs e monitoramento.
- Implemente política de retenção e eliminação de dados conforme a LGPD.
- Configure o gerenciamento de processos do worker.
- Implemente o provedor de cobrança recorrente escolhido.

**Importante:** o banco já possui estrutura para planos, assinaturas e registros de cobrança. A integração efetiva com um gateway de pagamento depende da implementação do respectivo provedor.

---

## Usuário de demonstração

O esquema inicial disponibiliza:

| Campo | Valor |
|---|---|
| E-mail | `admin@demo.local` |
| Senha inicial | `ChangeMe123!` |

**Atenção:** altere a senha antes de utilizar o sistema em qualquer ambiente compartilhado ou de produção.

---

## Roadmap

Possíveis evoluções do ConectaFlow:

- [ ] Integração com gateway de pagamento.
- [ ] Relatórios avançados de campanhas.
- [ ] Gestão de múltiplos atendentes e permissões.
- [ ] Notificações em tempo real.
- [ ] Relatórios de conversão dos funis.
- [ ] Exportação de relatórios.
- [ ] Monitoramento operacional.
- [ ] Aplicativo PWA.

---

## Sobre o projeto

O **ConectaFlow** foi concebido como uma solução SaaS para aproximar empresas de seus clientes por meio de uma comunicação organizada, profissional e integrada.

Mais do que uma ferramenta de disparos, a proposta é oferecer uma estrutura completa de relacionamento comercial: do primeiro contato ao acompanhamento, atendimento e conversão.

**ConectaFlow — Seu relacionamento com clientes, conectado em um só lugar.**

---

<sub>Desenvolvido com PHP, MySQL e integração oficial com a Meta WhatsApp Business Platform.</sub>
