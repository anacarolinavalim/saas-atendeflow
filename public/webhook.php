<?php
declare(strict_types=1);
require_once __DIR__.'/../src/Config.php'; require_once __DIR__.'/../src/Database.php'; require_once __DIR__.'/../src/Security.php'; require_once __DIR__.'/../src/Support.php';
use ConectaFlow\{Config,Database};
Config::load(__DIR__.'/../.env');
if ($_SERVER['REQUEST_METHOD']==='GET') { $mode=$_GET['hub_mode']??''; $token=$_GET['hub_verify_token']??''; $challenge=$_GET['hub_challenge']??''; if($mode==='subscribe' && hash_equals((string)Config::get('META_WEBHOOK_VERIFY_TOKEN',''),(string)$token)){http_response_code(200);echo $challenge;exit;} http_response_code(403);exit('forbidden'); }
$raw=file_get_contents('php://input') ?: ''; $signature=$_SERVER['HTTP_X_HUB_SIGNATURE_256']??''; $appSecret=(string)Config::get('META_APP_SECRET',''); $valid=false; if($appSecret && str_starts_with($signature,'sha256=')) $valid=hash_equals('sha256='.hash_hmac('sha256',$raw,$appSecret),$signature); if($appSecret && !$valid){http_response_code(401);exit('invalid signature');}
$payload=json_decode($raw,true) ?: []; try { $eventId=hash('sha256',$raw.microtime(true)); $stmt=Database::connection()->prepare('INSERT INTO webhook_events(provider_event_id,signature_valid,payload_json) VALUES(?,?,?)'); $stmt->execute([$eventId,$valid?1:0,json_encode($payload,JSON_UNESCAPED_UNICODE)]); http_response_code(200); echo 'EVENT_RECEIVED'; } catch(Throwable $e){http_response_code(500);echo 'retry';}
