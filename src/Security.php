<?php
namespace ConectaFlow;

final class Security
{
    public static function csrf(): string
    {
        if (empty($_SESSION['_csrf'])) $_SESSION['_csrf'] = bin2hex(random_bytes(32));
        return $_SESSION['_csrf'];
    }

    public static function validateCsrf(?string $token): void
    {
        if (!$token || !hash_equals($_SESSION['_csrf'] ?? '', $token)) {
            http_response_code(419); exit('Sessão expirada. Recarregue a página.');
        }
    }

    public static function e(mixed $value): string { return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8'); }

    public static function encrypt(string $plain): string
    {
        $key = hash('sha256', (string) Config::get('APP_KEY','change-me'), true);
        $iv = random_bytes(16);
        return base64_encode($iv . openssl_encrypt($plain, 'AES-256-CBC', $key, OPENSSL_RAW_DATA, $iv));
    }

    public static function decrypt(string $encoded): string
    {
        $raw = base64_decode($encoded, true); if ($raw === false) return '';
        $key = hash('sha256', (string) Config::get('APP_KEY','change-me'), true);
        return (string) openssl_decrypt(substr($raw, 16), 'AES-256-CBC', $key, OPENSSL_RAW_DATA, substr($raw, 0, 16));
    }
}
