<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Cấu hình này cho phép các request từ Flutter (web, mobile)
    | truy cập API Laravel qua HTTP. Có thể giới hạn domain nếu muốn.
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    // 👇 Cho phép mọi domain (Flutter web, mobile, emulator)
    // Nếu muốn giới hạn chỉ 1 domain, thay * bằng ví dụ:
    // ['http://localhost:49955', 'http://192.168.0.105:8000']
    'allowed_origins' => ['*'],

    // 👇 Cho phép mọi header (Authorization, Content-Type,...)
    'allowed_headers' => ['*'],

    // 👇 Đặt false nếu không dùng cookie/token với cross-site
    'supports_credentials' => false,

    // 👇 Cho phép thêm các header trả về (optional)
    'exposed_headers' => [],

    // 👇 Cache thời gian cấu hình CORS (giây)
    'max_age' => 0,
];
