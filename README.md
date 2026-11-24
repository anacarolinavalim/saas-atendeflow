# ConectaFlow

Micro SaaS multi-tenant para CRM, campanhas e atendimento via WhatsApp Business Platform / Meta Cloud API.

## O que já está incluído

- Autenticação com `password_hash`, sessão segura e CSRF.
- Isolamento por empresa em todas as consultas da aplicação.
- Dashboard com indicadores, gráficos e capacidade da conta.
- CRM de contatos, tags, grupos, consentimento e supressão.
- Campanhas segmentadas, prévia, agendamento e progresso.
- Fila persistente com lock, retentativas e idempotência.
- Cliente oficial da Meta Cloud API, webhook verificado e registro de eventos.
- Caixa de entrada com conversas e atribuição.
- Automações/funis com etapas persistidas.
- Planos, assinaturas, uso, faturamento e painel administrativo.
- Esquema MySQL normalizado, índices, foreign keys e dados iniciais.

## Requisitos

- PHP 8.2+ com extensões `pdo_mysql`, `curl`, `json`, `mbstring` e `openssl`.
- MySQL 8.0+.
- Composer (opcional; o projeto não depende de framework).
- Um cron ou worker contínuo para `bin/worker.php` e `bin/cron.php`.

## Instalação rápida

1. Copie `.env.example` para `.env` e preencha o banco.
2. Crie o banco e importe `database/schema.sql`.
3. Gere uma senha para o usuário inicial com `php bin/hash-password.php` e atualize o hash em `users`.
4. Sirva a pasta `public/` com PHP-FPM/Apache/Nginx. O document root deve ser `public/`.
5. Configure o webhook da Meta apontando para `https://SEU_DOMINIO/webhook.php`.
6. Execute um worker persistente: `php bin/worker.php`.
7. Execute o agendador a cada minuto: `php bin/cron.php`.

## Integração Meta

Cada empresa deve cadastrar sua própria WABA, Phone Number ID e token de acesso. Nunca reutilize tokens entre tenants. A tela de configurações persiste apenas um token criptografado quando `APP_KEY` estiver configurada; em produção, prefira um secret manager.

O cliente usa somente endpoints oficiais da Graph API. Templates, categorias, janela de atendimento, limites e custos devem ser confirmados na conta da empresa e nas regras vigentes da Meta. O sistema não implementa rotação de números, automação de WhatsApp Web ou qualquer contorno de limites.

O webhook valida o `META_WEBHOOK_VERIFY_TOKEN`, grava o payload bruto e atualiza mensagens/conversas de forma idempotente. Configure também `META_APP_SECRET` para validar a assinatura `X-Hub-Signature-256`.

## Segurança e operação

- Defina `APP_ENV=production`, `APP_KEY` forte e cookies HTTPS.
- Desabilite exibição de erros e envie logs para um coletor.
- Use um usuário MySQL sem privilégios de administração.
- Configure backups, retenção de logs e política LGPD de retenção/eliminação.
- Revise consentimento, templates aprovados e categorias antes de qualquer disparo.
- Adicione o provedor de cobrança recorrente escolhido implementando a interface de billing; o banco já suporta planos, assinaturas e registros de cobrança.

## Estrutura

```text
public/       front controller, webhook e assets
src/          autenticação, banco, Meta client e domínio
bin/          worker, cron e hash de senha
database/     schema MySQL
```

## Usuário inicial

O schema cria a empresa e um usuário de demonstração com e-mail `admin@demo.local` e senha inicial `ChangeMe123!`. Gere uma senha nova com o comando indicado acima e atualize o registro antes de usar em qualquer ambiente compartilhado.
