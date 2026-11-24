<?php
namespace ConectaFlow;

final class MetaClient
{
    public function __construct(private readonly string $token, private readonly string $version = 'v20.0') {}

    public function get(string $path, array $query = []): array { return $this->request('GET', $path, $query); }
    public function post(string $path, array $payload): array { return $this->request('POST', $path, $payload); }

    private function request(string $method, string $path, array $data): array
    {
        $url = 'https://graph.facebook.com/' . trim($this->version, '/') . '/' . ltrim($path, '/');
        if ($method === 'GET' && $data) $url .= '?' . http_build_query($data);
        $ch = curl_init($url);
        curl_setopt_array($ch, [CURLOPT_RETURNTRANSFER => true, CURLOPT_TIMEOUT => (int) Config::get('META_REQUEST_TIMEOUT', 30), CURLOPT_HTTPHEADER => ['Authorization: Bearer '.$this->token, 'Content-Type: application/json'], CURLOPT_CUSTOMREQUEST => $method]);
        if ($method !== 'GET') curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data, JSON_UNESCAPED_UNICODE));
        $body = curl_exec($ch); $status = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE); $error = curl_error($ch); curl_close($ch);
        if ($body === false || $error) throw new \RuntimeException('Falha de rede na Meta: '.$error);
        $decoded = json_decode($body, true) ?: [];
        if ($status >= 400) throw new \RuntimeException($decoded['error']['message'] ?? 'A Meta recusou a solicitação.');
        return $decoded;
    }
}
