<?php
namespace ConectaFlow;

function db(): \PDO { return Database::connection(); }
function userCompanyId(array $user): int { return (int) ($user['company_id'] ?? 0); }
function flash(string $type, string $message): void { $_SESSION['_flash'][] = ['type'=>$type, 'message'=>$message]; }
function takeFlashes(): array { $items = $_SESSION['_flash'] ?? []; unset($_SESSION['_flash']); return $items; }
function redirect(string $url): never { header('Location: '.$url); exit; }
function jsonResponse(array $payload, int $status=200): never { http_response_code($status); header('Content-Type: application/json'); echo json_encode($payload, JSON_UNESCAPED_UNICODE); exit; }
