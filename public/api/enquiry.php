<?php
/**
 * Enquiry form endpoint: receives the website's forms and emails them through Resend.
 *
 * The forms (src/components/EnquiryModal.astro) POST here. In order, this file:
 *   1. only accepts a POST from this website itself;
 *   2. drops anything that fills the hidden "botcheck" box (bots do, people can't);
 *   3. keeps only the fields listed in FORMS below, tidies them and checks the required ones;
 *   4. limits how many enquiries one visitor, and the whole site, can send (see the limits below);
 *   5. checks the visitor passed the Cloudflare Turnstile spam check;
 *   6. sends one email through Resend, with Reply-To set to the enquirer, so replying to the
 *      email writes back to them.
 *
 * The recipients are fixed in the settings: nothing a visitor sends can change who gets the email.
 * Each form can go to its own inbox (see ENQUIRY_TO in scripts/write-form-config.mjs).
 *
 * Settings live in config.php next to this file. It holds the Resend and Turnstile keys, so it is
 * NOT in the repository: the deploy writes it from the GitHub secrets (scripts/write-form-config.mjs).
 *
 * Opening this address in a browser (a GET) shows {"ok":true,"ready":true|false}: "ok" means PHP is
 * running here, "ready" that the settings file is in place.
 *
 * To reuse on another site: copy this file, then change SITE_NAME and FORMS.
 */

declare(strict_types=1);

const SITE_NAME = 'Derby Gala Dinner';

/**
 * The forms and their fields. Anything not listed is ignored.
 * Each field: [label in the email, required?, type, extra].
 *   text / tel: one line (max 200 characters)      email: must be an email address
 *   long: several lines (max 5000 characters)      choice: one of the listed values
 *   choices: one or more of the listed values, separated by commas
 * 'detail' names the field whose value is added to the subject line.
 */
const FORMS = [
    'booking' => [
        'subject' => 'Derby Gala Dinner: table reservation',
        'heading' => 'New table reservation',
        'detail' => 'table_type',
        'fields' => [
            'name' => ['Name', true, 'text'],
            'email' => ['Email', true, 'email'],
            'company' => ['Company name', false, 'text'],
            'phone' => ['Contact number', false, 'tel'],
            'address' => ['Company address', false, 'text'],
            'table_type' => ['Table type', true, 'choice', ['Evening Table', 'VIP Table']],
        ],
    ],
    'sponsorship' => [
        'subject' => 'Derby Gala Dinner: sponsorship enquiry',
        'heading' => 'New sponsorship enquiry',
        'detail' => 'sponsorship_type',
        'fields' => [
            'name' => ['Name', true, 'text'],
            'email' => ['Email', true, 'email'],
            'phone' => ['Phone number', false, 'tel'],
            'company' => ['Company name', false, 'text'],
            'sponsorship_type' => ['Sponsorship type', true, 'choices', ['Headline', 'Supporting', 'Welcome drinks', 'VIP lounge', 'Other']],
        ],
    ],
    'contact' => [
        'subject' => 'Derby Gala Dinner: general enquiry',
        'heading' => 'New general enquiry',
        'detail' => null,
        'fields' => [
            'title' => ['Title', false, 'choice', ['Mr', 'Mrs', 'Ms', 'Miss', 'Mx', 'Dr']],
            'first_name' => ['First name', true, 'text'],
            'surname' => ['Surname', true, 'text'],
            'email' => ['Email', true, 'email'],
            'phone' => ['Contact number', true, 'tel'],
            'company' => ['Company name', false, 'text'],
            'message' => ['Message', false, 'long'],
        ],
    ],
];

// Limits, so a flood of junk can't use up the Resend allowance (shared with other sites).
// config.php can override them with 'per_visitor_limit' and 'daily_limit'.
const PER_VISITOR_LIMIT = 5;      // enquiries from one visitor...
const PER_VISITOR_WINDOW = 900;   // ...in this many seconds (15 minutes)
const DAILY_LIMIT = 60;           // enquiries from this site in one day

const GENERIC_ERROR = "Sorry, your enquiry couldn't be sent. Please try again in a moment.";

// ---------------------------------------------------------------------------------------------

function respond(int $status, array $body): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');
    header('X-Robots-Tag: noindex');
    echo json_encode($body, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function cut(string $value, int $max): string
{
    return function_exists('mb_substr') ? mb_substr($value, 0, $max, 'UTF-8') : substr($value, 0, $max);
}

/** One line of text: no line breaks or control characters (so nothing can be smuggled into a subject line). */
function clean_line($value, int $max = 200): string
{
    if (!is_string($value)) {
        return '';
    }
    $value = preg_replace('/[\x00-\x1F\x7F]+/', ' ', $value) ?? '';
    $value = preg_replace('/ {2,}/', ' ', $value) ?? '';
    return cut(trim($value), $max);
}

/** Several lines of text: line breaks kept, other control characters removed. */
function clean_text($value, int $max = 5000): string
{
    if (!is_string($value)) {
        return '';
    }
    $value = str_replace(["\r\n", "\r"], "\n", $value);
    $value = preg_replace('/[\x00-\x09\x0B-\x1F\x7F]+/', ' ', $value) ?? '';
    $value = preg_replace("/\n{3,}/", "\n\n", $value) ?? '';
    return cut(trim($value), $max);
}

/** POST a request and return ['status' => int, 'body' => string]. status 0 = couldn't connect. */
function http_post(string $url, array $headers, string $body, int $timeout = 12): array
{
    if (function_exists('curl_init')) {
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $body,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CONNECTTIMEOUT => 6,
            CURLOPT_TIMEOUT => $timeout,
        ]);
        $response = curl_exec($ch);
        $status = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        return ['status' => $response === false ? 0 : $status, 'body' => is_string($response) ? $response : ''];
    }

    $context = stream_context_create(['http' => [
        'method' => 'POST',
        'header' => implode("\r\n", $headers),
        'content' => $body,
        'timeout' => $timeout,
        'ignore_errors' => true,
    ]]);
    $response = @file_get_contents($url, false, $context);
    $status = 0;
    if (isset($http_response_header[0]) && preg_match('/\s(\d{3})\s/', $http_response_header[0], $m)) {
        $status = (int) $m[1];
    }
    return ['status' => $response === false ? 0 : $status, 'body' => is_string($response) ? $response : ''];
}

/**
 * Count this enquiry against the limits. Returns false if a limit has been reached.
 * Kept in one small file in the server's temp folder; visitors are stored as a scrambled value,
 * never as an IP address. If the file can't be used, nothing is limited (enquiries still send).
 */
function within_limits(string $ip, int $perVisitor, int $daily): bool
{
    $file = rtrim(sys_get_temp_dir(), '/\\') . '/enquiry-' . md5(__FILE__) . '.json';
    $handle = @fopen($file, 'c+');
    if (!$handle) {
        return true;
    }
    if (!flock($handle, LOCK_EX)) {
        fclose($handle);
        return true;
    }

    $now = time();
    $today = gmdate('Y-m-d', $now);
    $state = json_decode((string) stream_get_contents($handle), true);
    if (!is_array($state) || ($state['day'] ?? '') !== $today) {
        $state = ['day' => $today, 'count' => 0, 'visitors' => []];
    }

    $visitor = substr(hash('sha256', __FILE__ . '|' . $ip), 0, 24);
    $visitors = [];
    foreach ((array) ($state['visitors'] ?? []) as $key => $times) {
        $recent = array_values(array_filter((array) $times, function ($t) use ($now) {
            return is_int($t) && $t > $now - PER_VISITOR_WINDOW;
        }));
        if ($recent) {
            $visitors[$key] = $recent;
        }
    }
    $mine = $visitors[$visitor] ?? [];

    $allowed = (int) $state['count'] < $daily && count($mine) < $perVisitor;
    if ($allowed) {
        $mine[] = $now;
        $visitors[$visitor] = $mine;
        $state['count'] = (int) $state['count'] + 1;
    }
    $state['visitors'] = $visitors;

    ftruncate($handle, 0);
    rewind($handle);
    fwrite($handle, (string) json_encode($state));
    fflush($handle);
    flock($handle, LOCK_UN);
    fclose($handle);
    return $allowed;
}

// ---------------------------------------------------------------------------------------------

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$configFile = __DIR__ . '/config.php';
$config = is_file($configFile) ? require $configFile : null;
$ready = is_array($config)
    && !empty($config['resend_api_key']) && !empty($config['turnstile_secret'])
    && !empty($config['to']) && !empty($config['from']);

if ($method === 'GET' || $method === 'HEAD') {
    respond(200, ['ok' => true, 'ready' => $ready]);
}
if ($method !== 'POST') {
    header('Allow: GET, POST');
    respond(405, ['success' => false, 'message' => 'Method not allowed.']);
}

// 1. Only from this website. Browsers say which site a POST came from; it must be this one.
$host = strtolower((string) preg_replace('/:\d+$/', '', $_SERVER['HTTP_HOST'] ?? ''));
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
if ($origin !== '' && strtolower((string) parse_url($origin, PHP_URL_HOST)) !== $host) {
    respond(403, ['success' => false, 'message' => GENERIC_ERROR]);
}
if ((int) ($_SERVER['CONTENT_LENGTH'] ?? 0) > 100000) {
    respond(413, ['success' => false, 'message' => GENERIC_ERROR]);
}

if (!$ready) {
    error_log('enquiry.php: config.php is missing or incomplete');
    respond(503, ['success' => false, 'code' => 'not_configured', 'message' => GENERIC_ERROR]);
}

// 2. The hidden box. A bot that fills it is told all is well and nothing is sent.
if (!empty($_POST['botcheck'])) {
    respond(200, ['success' => true]);
}

// 3. The fields.
$formName = is_string($_POST['form'] ?? null) ? $_POST['form'] : '';
if (!isset(FORMS[$formName])) {
    respond(400, ['success' => false, 'message' => GENERIC_ERROR]);
}
$form = FORMS[$formName];

// Who gets this form: one list for every form, or a list per form (with an optional 'default').
$recipients = $config['to'];
if (is_array($recipients)) {
    $recipients = $recipients[$formName] ?? ($recipients['default'] ?? '');
}
$to = array_values(array_filter(array_map('trim', explode(',', (string) $recipients)), 'strlen'));
if (!$to) {
    error_log('enquiry.php: no recipient is set for the "' . $formName . '" form');
    respond(503, ['success' => false, 'code' => 'not_configured', 'message' => GENERIC_ERROR]);
}

$values = [];
$problems = [];
foreach ($form['fields'] as $key => $spec) {
    $required = $spec[1];
    $type = $spec[2];
    $raw = $_POST[$key] ?? '';

    if ($type === 'long') {
        $value = clean_text($raw);
    } elseif ($type === 'choices') {
        $picked = array_filter(array_map('trim', explode(',', clean_line($raw, 500))), 'strlen');
        $value = implode(', ', array_values(array_unique($picked)));
        if ($picked && array_diff($picked, $spec[3])) {
            $problems[] = $key;
        }
    } else {
        $value = clean_line($raw);
        if ($value !== '' && $type === 'email' && !filter_var($value, FILTER_VALIDATE_EMAIL)) {
            $problems[] = $key;
        }
        if ($value !== '' && $type === 'choice' && !in_array($value, $spec[3], true)) {
            $problems[] = $key;
        }
    }

    if ($required && $value === '') {
        $problems[] = $key;
    }
    $values[$key] = $value;
}
if ($problems) {
    respond(422, [
        'success' => false,
        'code' => 'invalid',
        'fields' => array_values(array_unique($problems)),
        'message' => 'Please check the highlighted fields and try again.',
    ]);
}

// 4. Limits.
$ip = (string) ($_SERVER['REMOTE_ADDR'] ?? '');
$perVisitor = (int) ($config['per_visitor_limit'] ?? PER_VISITOR_LIMIT);
$daily = (int) ($config['daily_limit'] ?? DAILY_LIMIT);

// 5. The spam check. A token is good for one use, so it is checked only once everything else is fine.
$token = is_string($_POST['cf-turnstile-response'] ?? null) ? $_POST['cf-turnstile-response'] : '';
if ($token === '' || strlen($token) > 4096) {
    respond(400, ['success' => false, 'code' => 'captcha', 'message' => 'Please complete the security check and try again.']);
}
$check = http_post(
    $config['turnstile_url'] ?? 'https://challenges.cloudflare.com/turnstile/v0/siteverify',
    ['Content-Type: application/x-www-form-urlencoded'],
    http_build_query(['secret' => $config['turnstile_secret'], 'response' => $token, 'remoteip' => $ip])
);
$verdict = json_decode($check['body'], true);
if ($check['status'] !== 200 || !is_array($verdict)) {
    error_log('enquiry.php: Turnstile could not be reached (status ' . $check['status'] . ')');
    respond(502, ['success' => false, 'message' => GENERIC_ERROR]);
}
if (empty($verdict['success'])) {
    respond(400, ['success' => false, 'code' => 'captcha', 'message' => 'The security check failed. Please try it again.']);
}

if (!within_limits($ip, $perVisitor, $daily)) {
    error_log('enquiry.php: enquiry limit reached');
    respond(429, [
        'success' => false,
        'code' => 'limit',
        'message' => "We can't take any more enquiries through this form right now. Please try again later.",
    ]);
}

// 6. The email.
$subject = $form['subject'];
if ($form['detail'] !== null && $values[$form['detail']] !== '') {
    $subject .= ' (' . $values[$form['detail']] . ')';
}

$who = $values['name'] ?? trim(($values['first_name'] ?? '') . ' ' . ($values['surname'] ?? ''));
$intro = $form['heading'] . ' from the ' . SITE_NAME . ' website';
$footer = 'Reply to this email to reply to ' . ($who !== '' ? $who : 'the sender') . ' (' . $values['email'] . ').';

$text = $intro . "\n\n";
$rows = '';
foreach ($form['fields'] as $key => $spec) {
    if ($values[$key] === '') {
        continue;
    }
    $long = $spec[2] === 'long';
    $text .= $spec[0] . ':' . ($long ? "\n" : ' ') . $values[$key] . "\n" . ($long ? "\n" : '');
    $rows .= '<tr><td style="padding:6px 16px 6px 0;vertical-align:top;color:#666;white-space:nowrap">'
        . htmlspecialchars($spec[0], ENT_QUOTES, 'UTF-8') . '</td><td style="padding:6px 0;vertical-align:top">'
        . nl2br(htmlspecialchars($values[$key], ENT_QUOTES, 'UTF-8')) . '</td></tr>';
}
$text = rtrim($text) . "\n\n" . $footer . "\n";
$html = '<div style="font-family:Arial,Helvetica,sans-serif;font-size:15px;line-height:1.5;color:#111">'
    . '<p style="font-size:17px;margin:0 0 12px"><strong>' . htmlspecialchars($intro, ENT_QUOTES, 'UTF-8') . '</strong></p>'
    . '<table cellpadding="0" cellspacing="0" style="border-collapse:collapse">' . $rows . '</table>'
    . '<p style="margin:16px 0 0;color:#666">' . htmlspecialchars($footer, ENT_QUOTES, 'UTF-8') . '</p></div>';

$sent = http_post(
    $config['resend_url'] ?? 'https://api.resend.com/emails',
    [
        'Authorization: Bearer ' . $config['resend_api_key'],
        'Content-Type: application/json',
        'User-Agent: website-enquiry-form/1.0',
    ],
    (string) json_encode([
        'from' => $config['from'],
        'to' => $to,
        'reply_to' => $values['email'],
        'subject' => $subject,
        'text' => $text,
        'html' => $html,
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)
);

if ($sent['status'] < 200 || $sent['status'] >= 300) {
    // Logged without the enquirer's details. Resend's reply says what was wrong (bad key, limit reached...).
    error_log('enquiry.php: Resend refused the email (status ' . $sent['status'] . '): ' . cut(clean_line($sent['body'], 400), 400));
    respond(502, ['success' => false, 'code' => 'send', 'message' => GENERIC_ERROR]);
}

respond(200, ['success' => true]);
