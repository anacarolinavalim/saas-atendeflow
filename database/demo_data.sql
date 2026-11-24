USE conectaflow;

-- Dados demonstrativos idempotentes. Não dispara mensagens reais.
INSERT IGNORE INTO tags (id,company_id,name,color) VALUES
(1,1,'Cliente ativo','#22B893'),(2,1,'Lead quente','#F0A15B'),(3,1,'VIP','#8E83ED'),(4,1,'Pós-venda','#69B5DB');
INSERT IGNORE INTO contact_groups (id,company_id,name,description) VALUES
(1,1,'Clientes ativos','Clientes com relacionamento vigente'),(2,1,'Leads novembro','Leads captados nas campanhas de novembro');
INSERT IGNORE INTO contacts (id,company_id,name,phone,email,contact_company,source,status,last_interaction_at) VALUES
(1,1,'Marina Costa','5511998765432','marina@aurora.com.br','Aurora Studio','Indicação','active',NOW()-INTERVAL 18 MINUTE),
(2,1,'Rafael Mendes','5511987654321','rafael@montreal.com.br','Montreal Contábil','Landing page','active',NOW()-INTERVAL 2 HOUR),
(3,1,'Camila Oliveira','5511976543210','camila@casaoliva.com.br','Casa Oliva','Instagram','active',NOW()-INTERVAL 1 DAY),
(4,1,'João Pedro','5511965432109','joao@jpengenharia.com.br','JP Engenharia','Evento','active',NOW()-INTERVAL 2 DAY),
(5,1,'Beatriz Souza','5511954321098','bia@novomundo.com.br','Novo Mundo','Indicação','active',NOW()-INTERVAL 3 DAY),
(6,1,'Lucas Almeida','5511943210987','lucas@studioalto.com.br','Studio Alto','Importação manual','inactive',NOW()-INTERVAL 12 DAY);
INSERT IGNORE INTO contact_tags (contact_id,tag_id) VALUES (1,1),(1,3),(2,2),(3,1),(3,4),(4,2),(5,3),(6,4);
INSERT IGNORE INTO contact_group_members (group_id,contact_id) VALUES (1,1),(1,3),(1,5),(2,2),(2,4),(2,6);
INSERT IGNORE INTO consent_records (company_id,contact_id,consent_type,status,source,evidence) VALUES
(1,1,'marketing','granted','formulario','Aceite demonstrativo'),(1,2,'marketing','granted','landing_page','Aceite demonstrativo'),(1,3,'marketing','granted','instagram','Aceite demonstrativo'),(1,4,'marketing','granted','evento','Aceite demonstrativo'),(1,5,'marketing','granted','indicacao','Aceite demonstrativo'),(1,6,'marketing','revoked','whatsapp','Solicitou descadastro');
INSERT IGNORE INTO suppression_list (company_id,phone,reason) VALUES (1,'5511943210987','opt_out');
INSERT IGNORE INTO campaigns (id,company_id,created_by,name,category,message_text,audience_filter_json,status,scheduled_at,total_count,sent_count,delivered_count,read_count,replied_count,failed_count,estimated_cost_cents,started_at,completed_at,created_at) VALUES
(1,1,1,'Boas-vindas novembro','marketing','Olá, {{nome}}! Seja bem-vindo à nossa comunidade.','{"status":"active","tag":""}','completed',NULL,5,5,5,4,2,0,0,NOW()-INTERVAL 6 DAY,NOW()-INTERVAL 6 DAY,NOW()-INTERVAL 7 DAY),
(2,1,1,'Convite clientes VIP','marketing','Olá, {{nome}}! Preparamos uma experiência especial para você.','{"status":"active","tag":"VIP"}','processing',NULL,2,1,1,1,1,0,0,NOW()-INTERVAL 42 MINUTE,NULL,NOW()-INTERVAL 1 HOUR),
(3,1,1,'Lembrete de atendimento','utility','Oi, {{nome}}! Este é um lembrete do seu atendimento amanhã.','{"status":"active","tag":"Cliente ativo"}','scheduled',DATE_ADD(NOW(),INTERVAL 1 DAY),3,0,0,0,0,0,0,NULL,NULL,NOW()-INTERVAL 3 HOUR),
(4,1,1,'Reativação de leads','marketing','Olá, {{nome}}! Podemos ajudar com alguma dúvida?','{"status":"active","tag":"Lead quente"}','draft',NULL,0,0,0,0,0,0,0,NULL,NULL,NOW()-INTERVAL 20 MINUTE);
INSERT IGNORE INTO campaign_contacts (id,campaign_id,contact_id,status,provider_message_id,queued_at,sent_at) VALUES
(1,1,1,'read','demo-msg-001',NOW()-INTERVAL 6 DAY,NOW()-INTERVAL 6 DAY),(2,1,2,'read','demo-msg-002',NOW()-INTERVAL 6 DAY,NOW()-INTERVAL 6 DAY),(3,1,3,'replied','demo-msg-003',NOW()-INTERVAL 6 DAY,NOW()-INTERVAL 6 DAY),(4,1,4,'delivered','demo-msg-004',NOW()-INTERVAL 6 DAY,NOW()-INTERVAL 6 DAY),(5,1,5,'delivered','demo-msg-005',NOW()-INTERVAL 6 DAY,NOW()-INTERVAL 6 DAY),(6,2,1,'read','demo-msg-006',NOW()-INTERVAL 42 MINUTE,NOW()-INTERVAL 41 MINUTE),(7,2,5,'sent','demo-msg-007',NOW()-INTERVAL 40 MINUTE,NOW()-INTERVAL 39 MINUTE),(8,3,1,'pending',NULL,NULL,NULL),(9,3,3,'pending',NULL,NULL,NULL),(10,3,5,'pending',NULL,NULL,NULL);
INSERT IGNORE INTO messages (id,company_id,contact_id,campaign_id,direction,body,provider_message_id,status,created_at) VALUES
(1,1,1,1,'outbound','Olá, Marina! Seja bem-vinda à nossa comunidade.','demo-msg-001','read',NOW()-INTERVAL 6 DAY),(2,1,2,1,'outbound','Olá, Rafael! Seja bem-vindo à nossa comunidade.','demo-msg-002','read',NOW()-INTERVAL 6 DAY),(3,1,3,1,'outbound','Olá, Camila! Seja bem-vinda à nossa comunidade.','demo-msg-003','read',NOW()-INTERVAL 6 DAY),(4,1,3,1,'inbound','Obrigada! Adorei receber a mensagem.','demo-in-001','read',NOW()-INTERVAL 5 DAY),(5,1,4,1,'outbound','Olá, João! Seja bem-vindo à nossa comunidade.','demo-msg-004','delivered',NOW()-INTERVAL 6 DAY),(6,1,5,1,'outbound','Olá, Beatriz! Seja bem-vinda à nossa comunidade.','demo-msg-005','delivered',NOW()-INTERVAL 6 DAY),(7,1,1,2,'outbound','Olá, Marina! Preparamos uma experiência especial para você.','demo-msg-006','read',NOW()-INTERVAL 41 MINUTE),(8,1,1,2,'inbound','Que ótimo! Pode me contar mais?','demo-in-002','read',NOW()-INTERVAL 35 MINUTE),(9,1,5,2,'outbound','Olá, Beatriz! Preparamos uma experiência especial para você.','demo-msg-007','sent',NOW()-INTERVAL 39 MINUTE);
INSERT IGNORE INTO conversations (id,company_id,contact_id,status,assigned_to,last_message_at,window_expires_at) VALUES
(1,1,1,'in_progress',1,NOW()-INTERVAL 35 MINUTE,DATE_ADD(NOW()-INTERVAL 35 MINUTE,INTERVAL 23 HOUR)),(2,1,3,'resolved',1,NOW()-INTERVAL 5 DAY,DATE_ADD(NOW()-INTERVAL 5 DAY,INTERVAL 23 HOUR)),(3,1,2,'new',NULL,NOW()-INTERVAL 2 HOUR,DATE_ADD(NOW()-INTERVAL 2 HOUR,INTERVAL 23 HOUR));
INSERT IGNORE INTO automation_flows (id,company_id,created_by,name,trigger_type,status) VALUES (1,1,1,'Pós-venda essencial','message_received','active'),(2,1,1,'Recuperação de leads','tag_added','draft');
INSERT IGNORE INTO automation_steps (id,flow_id,position,step_type,config_json) VALUES (1,1,1,'delay','{"minutes":30}'),(2,1,2,'action','{"type":"send_template","template":"pos_venda_01"}'),(3,1,3,'condition','{"field":"status","equals":"active"}'),(4,2,1,'delay','{"hours":24}'),(5,2,2,'action','{"type":"send_template","template":"recuperacao_lead_01"}');
INSERT IGNORE INTO usage_records (company_id,period_month,category,messages_count,cost_cents) VALUES (1,DATE_FORMAT(CURRENT_DATE,'%Y-%m-01'),'marketing',7,0),(1,DATE_FORMAT(CURRENT_DATE,'%Y-%m-01'),'utility',0,0),(1,DATE_FORMAT(CURRENT_DATE,'%Y-%m-01'),'service',2,0);
