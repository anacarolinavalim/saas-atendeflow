<?php
namespace ConectaFlow;

final class Auth
{
    public static function user(): ?array { return $_SESSION['user'] ?? null; }
    public static function login(string $email, string $password): bool
    {
        $stmt = Database::connection()->prepare('SELECT * FROM users WHERE email = ? AND status = "active" LIMIT 1');
        $stmt->execute([$email]); $user = $stmt->fetch();
        if (!$user || !password_verify($password, $user['password_hash'])) return false;
        session_regenerate_id(true); unset($user['password_hash']); $_SESSION['user'] = $user;
        Database::connection()->prepare('UPDATE users SET last_login_at = NOW() WHERE id = ?')->execute([$user['id']]);
        return true;
    }
    public static function logout(): void { $_SESSION = []; if (ini_get('session.use_cookies')) { $p = session_get_cookie_params(); setcookie(session_name(), '', time()-42000, $p['path'], $p['domain'], $p['secure'], $p['httponly']); } session_destroy(); }
    public static function requireLogin(): array { $user = self::user(); if (!$user) { header('Location: ?page=login'); exit; } return $user; }
    public static function requireAdmin(array $user): void { if ($user['role'] !== 'admin') { http_response_code(403); exit('Acesso restrito ao administrador da plataforma.'); } }
}
