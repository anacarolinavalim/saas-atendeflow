CREATE DATABASE IF NOT EXISTS conectaflow CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE conectaflow;

CREATE TABLE plans (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  code VARCHAR(40) NOT NULL UNIQUE,
  monthly_price_cents INT UNSIGNED NOT NULL DEFAULT 0,
  limits_json JSON NOT NULL,
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE companies (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(160) NOT NULL,
  legal_name VARCHAR(200) NULL,
  document VARCHAR(40) NULL,
  status ENUM('active','blocked','trial') NOT NULL DEFAULT 'trial',
  timezone VARCHAR(64) NOT NULL DEFAULT 'America/Sao_Paulo',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NULL,
  name VARCHAR(160) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('owner','manager','agent','admin') NOT NULL DEFAULT 'agent',
  status ENUM('active','blocked') NOT NULL DEFAULT 'active',
  last_login_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL,
  INDEX idx_users_company_status (company_id, status)
) ENGINE=InnoDB;

CREATE TABLE subscriptions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  plan_id BIGINT UNSIGNED NOT NULL,
  provider VARCHAR(40) NULL,
  provider_subscription_id VARCHAR(160) NULL,
  status ENUM('trialing','active','past_due','canceled','paused') NOT NULL DEFAULT 'trialing',
  current_period_start DATE NULL,
  current_period_end DATE NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_subscription_provider (provider, provider_subscription_id),
  CONSTRAINT fk_sub_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT fk_sub_plan FOREIGN KEY (plan_id) REFERENCES plans(id)
) ENGINE=InnoDB;

CREATE TABLE contacts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(160) NOT NULL,
  phone VARCHAR(32) NOT NULL,
  email VARCHAR(190) NULL,
  contact_company VARCHAR(160) NULL,
  source VARCHAR(80) NULL,
  status ENUM('active','inactive','blocked') NOT NULL DEFAULT 'active',
  opted_out_at DATETIME NULL,
  last_interaction_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_contact_phone (company_id, phone),
  INDEX idx_contacts_filter (company_id, status, created_at),
  CONSTRAINT fk_contacts_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tags (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(80) NOT NULL,
  color CHAR(7) NOT NULL DEFAULT '#22D3A6',
  UNIQUE KEY uq_tag_company_name (company_id, name),
  CONSTRAINT fk_tags_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE contact_tags (
  contact_id BIGINT UNSIGNED NOT NULL,
  tag_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (contact_id, tag_id),
  CONSTRAINT fk_ct_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE,
  CONSTRAINT fk_ct_tag FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE contact_groups (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  description VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_group_company_name (company_id, name),
  CONSTRAINT fk_groups_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE contact_group_members (
  group_id BIGINT UNSIGNED NOT NULL,
  contact_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (group_id, contact_id),
  CONSTRAINT fk_cgm_group FOREIGN KEY (group_id) REFERENCES contact_groups(id) ON DELETE CASCADE,
  CONSTRAINT fk_cgm_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE consent_records (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  contact_id BIGINT UNSIGNED NOT NULL,
  consent_type ENUM('marketing','utility','service') NOT NULL,
  status ENUM('granted','revoked') NOT NULL,
  source VARCHAR(120) NULL,
  evidence TEXT NULL,
  recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_consent_contact (company_id, contact_id, consent_type, recorded_at),
  CONSTRAINT fk_consent_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT fk_consent_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE suppression_list (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  phone VARCHAR(32) NOT NULL,
  reason VARCHAR(160) NOT NULL DEFAULT 'opt_out',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_suppression_phone (company_id, phone),
  CONSTRAINT fk_suppression_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE whatsapp_accounts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  waba_id VARCHAR(120) NOT NULL,
  access_token_encrypted TEXT NOT NULL,
  status ENUM('connected','needs_attention','disconnected') NOT NULL DEFAULT 'connected',
  quality_rating VARCHAR(40) NULL,
  messaging_limit VARCHAR(80) NULL,
  last_sync_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_waba_company (company_id, waba_id),
  CONSTRAINT fk_wa_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE whatsapp_numbers (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  whatsapp_account_id BIGINT UNSIGNED NOT NULL,
  phone_number_id VARCHAR(120) NOT NULL,
  display_phone_number VARCHAR(40) NULL,
  verified_name VARCHAR(160) NULL,
  status VARCHAR(60) NULL,
  quality_rating VARCHAR(40) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_phone_number (whatsapp_account_id, phone_number_id),
  CONSTRAINT fk_wn_account FOREIGN KEY (whatsapp_account_id) REFERENCES whatsapp_accounts(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE whatsapp_templates (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  whatsapp_account_id BIGINT UNSIGNED NOT NULL,
  meta_template_id VARCHAR(120) NULL,
  name VARCHAR(120) NOT NULL,
  language VARCHAR(20) NOT NULL DEFAULT 'pt_BR',
  category ENUM('marketing','utility','authentication') NOT NULL,
  status VARCHAR(40) NOT NULL DEFAULT 'PENDING',
  components_json JSON NOT NULL,
  synced_at DATETIME NULL,
  UNIQUE KEY uq_template_account_name_lang (whatsapp_account_id, name, language),
  CONSTRAINT fk_templates_account FOREIGN KEY (whatsapp_account_id) REFERENCES whatsapp_accounts(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE campaigns (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  name VARCHAR(160) NOT NULL,
  category ENUM('marketing','utility','authentication') NOT NULL DEFAULT 'marketing',
  template_id BIGINT UNSIGNED NULL,
  message_text TEXT NULL,
  media_url VARCHAR(500) NULL,
  audience_filter_json JSON NOT NULL,
  status ENUM('draft','scheduled','processing','completed','paused','canceled') NOT NULL DEFAULT 'draft',
  scheduled_at DATETIME NULL,
  total_count INT UNSIGNED NOT NULL DEFAULT 0,
  sent_count INT UNSIGNED NOT NULL DEFAULT 0,
  delivered_count INT UNSIGNED NOT NULL DEFAULT 0,
  read_count INT UNSIGNED NOT NULL DEFAULT 0,
  replied_count INT UNSIGNED NOT NULL DEFAULT 0,
  failed_count INT UNSIGNED NOT NULL DEFAULT 0,
  estimated_cost_cents INT UNSIGNED NOT NULL DEFAULT 0,
  started_at DATETIME NULL,
  completed_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_campaign_company_status (company_id, status, scheduled_at),
  CONSTRAINT fk_campaign_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT fk_campaign_user FOREIGN KEY (created_by) REFERENCES users(id),
  CONSTRAINT fk_campaign_template FOREIGN KEY (template_id) REFERENCES whatsapp_templates(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE campaign_contacts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  campaign_id BIGINT UNSIGNED NOT NULL,
  contact_id BIGINT UNSIGNED NOT NULL,
  status ENUM('pending','queued','sent','delivered','read','replied','failed','suppressed') NOT NULL DEFAULT 'pending',
  provider_message_id VARCHAR(180) NULL,
  last_error VARCHAR(500) NULL,
  queued_at DATETIME NULL,
  sent_at DATETIME NULL,
  UNIQUE KEY uq_campaign_contact (campaign_id, contact_id),
  INDEX idx_campaign_contacts_queue (campaign_id, status),
  CONSTRAINT fk_cc_campaign FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE,
  CONSTRAINT fk_cc_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE messages (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  contact_id BIGINT UNSIGNED NOT NULL,
  campaign_id BIGINT UNSIGNED NULL,
  direction ENUM('inbound','outbound') NOT NULL,
  type VARCHAR(40) NOT NULL DEFAULT 'text',
  body TEXT NULL,
  provider_message_id VARCHAR(180) NULL,
  status ENUM('queued','sent','delivered','read','failed') NOT NULL DEFAULT 'queued',
  error_code VARCHAR(80) NULL,
  error_message VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_provider_message (provider_message_id),
  INDEX idx_messages_conversation (company_id, contact_id, created_at),
  CONSTRAINT fk_messages_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT fk_messages_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE,
  CONSTRAINT fk_messages_campaign FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE message_queue (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  campaign_id BIGINT UNSIGNED NOT NULL,
  campaign_contact_id BIGINT UNSIGNED NOT NULL,
  available_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  locked_at DATETIME NULL,
  attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
  status ENUM('pending','processing','done','failed') NOT NULL DEFAULT 'pending',
  last_error VARCHAR(500) NULL,
  UNIQUE KEY uq_queue_campaign_contact (campaign_contact_id),
  INDEX idx_queue_ready (status, available_at, locked_at),
  CONSTRAINT fk_queue_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT fk_queue_campaign FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE,
  CONSTRAINT fk_queue_campaign_contact FOREIGN KEY (campaign_contact_id) REFERENCES campaign_contacts(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE message_events (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  message_id BIGINT UNSIGNED NULL,
  provider_message_id VARCHAR(180) NULL,
  event_type VARCHAR(60) NOT NULL,
  payload_json JSON NOT NULL,
  occurred_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_message_event (provider_message_id, event_type, occurred_at),
  CONSTRAINT fk_events_message FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE conversations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  contact_id BIGINT UNSIGNED NOT NULL,
  status ENUM('new','in_progress','pending','resolved') NOT NULL DEFAULT 'new',
  assigned_to BIGINT UNSIGNED NULL,
  last_message_at DATETIME NULL,
  window_expires_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_conversation_contact (company_id, contact_id),
  CONSTRAINT fk_conv_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT fk_conv_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE,
  CONSTRAINT fk_conv_agent FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE automation_flows (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  name VARCHAR(160) NOT NULL,
  trigger_type VARCHAR(80) NOT NULL,
  status ENUM('active','paused','draft') NOT NULL DEFAULT 'draft',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_flows_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT fk_flows_user FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE automation_steps (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  flow_id BIGINT UNSIGNED NOT NULL,
  position SMALLINT UNSIGNED NOT NULL,
  step_type ENUM('condition','action','delay') NOT NULL,
  config_json JSON NOT NULL,
  CONSTRAINT fk_steps_flow FOREIGN KEY (flow_id) REFERENCES automation_flows(id) ON DELETE CASCADE,
  UNIQUE KEY uq_flow_position (flow_id, position)
) ENGINE=InnoDB;

CREATE TABLE automation_executions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  flow_id BIGINT UNSIGNED NOT NULL,
  contact_id BIGINT UNSIGNED NOT NULL,
  status ENUM('running','completed','failed','canceled') NOT NULL DEFAULT 'running',
  current_step SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  context_json JSON NOT NULL,
  next_run_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_exec_flow FOREIGN KEY (flow_id) REFERENCES automation_flows(id) ON DELETE CASCADE,
  CONSTRAINT fk_exec_contact FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE usage_records (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  whatsapp_number_id BIGINT UNSIGNED NULL,
  period_month DATE NOT NULL,
  category ENUM('marketing','utility','authentication','service') NOT NULL,
  messages_count INT UNSIGNED NOT NULL DEFAULT 0,
  cost_cents INT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_usage_month (company_id, whatsapp_number_id, period_month, category),
  CONSTRAINT fk_usage_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
  CONSTRAINT fk_usage_number FOREIGN KEY (whatsapp_number_id) REFERENCES whatsapp_numbers(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE billing_records (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NOT NULL,
  type ENUM('subscription','meta_usage','credit','refund') NOT NULL,
  amount_cents INT NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'BRL',
  description VARCHAR(255) NOT NULL,
  provider_invoice_id VARCHAR(160) NULL,
  status ENUM('pending','paid','failed','void') NOT NULL DEFAULT 'pending',
  issued_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  paid_at DATETIME NULL,
  CONSTRAINT fk_billing_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE webhook_events (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NULL,
  provider_event_id VARCHAR(180) NULL,
  signature_valid TINYINT(1) NOT NULL DEFAULT 0,
  payload_json JSON NOT NULL,
  processed_at DATETIME NULL,
  received_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_webhook_event (provider_event_id),
  CONSTRAINT fk_webhook_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE system_settings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(120) NOT NULL UNIQUE,
  setting_value TEXT NULL,
  is_secret TINYINT(1) NOT NULL DEFAULT 0,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id BIGINT UNSIGNED NULL,
  user_id BIGINT UNSIGNED NULL,
  action VARCHAR(120) NOT NULL,
  entity_type VARCHAR(80) NULL,
  entity_id BIGINT UNSIGNED NULL,
  metadata_json JSON NULL,
  ip_address VARCHAR(45) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_audit_company_time (company_id, created_at),
  CONSTRAINT fk_audit_company FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL,
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

INSERT INTO plans (name, code, monthly_price_cents, limits_json) VALUES
('Básico','basic',9900,'{"contacts":2000,"numbers":1,"users":2,"campaigns_month":20,"automations":0}'),
('Profissional','pro',24900,'{"contacts":10000,"numbers":3,"users":10,"campaigns_month":100,"automations":20}'),
('Empresarial','enterprise',59900,'{"contacts":50000,"numbers":10,"users":50,"campaigns_month":500,"automations":100}');

INSERT INTO companies (name, legal_name, status) VALUES ('Empresa Demo','Empresa Demo LTDA','trial');
INSERT INTO users (company_id, name, email, password_hash, role) VALUES (1, 'Administrador Demo', 'admin@demo.local', '$2y$10$bS5Gv1Hm8kY4HqY4EQJEOOXEjFowROqpIWn77dxR5ulurwF/pKlre', 'owner');
INSERT INTO subscriptions (company_id, plan_id, status, current_period_start, current_period_end) VALUES (1, 1, 'trialing', CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY));
