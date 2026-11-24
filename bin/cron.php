<?php
declare(strict_types=1);
require_once __DIR__.'/../src/Config.php'; require_once __DIR__.'/../src/Database.php';
use ConectaFlow\{Config,Database}; Config::load(__DIR__.'/../.env'); $pdo=Database::connection();
$pdo->exec('UPDATE campaigns c SET c.status="processing", c.started_at=COALESCE(c.started_at,NOW()) WHERE c.status="scheduled" AND c.scheduled_at<=NOW()');
$pdo->exec('INSERT IGNORE INTO message_queue(company_id,campaign_id,campaign_contact_id) SELECT c.company_id,c.id,cc.id FROM campaigns c JOIN campaign_contacts cc ON cc.campaign_id=c.id WHERE c.status="processing" AND cc.status="pending"');
$pdo->exec('UPDATE campaigns c SET c.status="completed",c.completed_at=NOW() WHERE c.status="processing" AND c.total_count>0 AND c.sent_count+c.failed_count>=c.total_count');
echo "cron ok ".date('c').PHP_EOL;
