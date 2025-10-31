<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\SongController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
| Các route dành cho app Flutter gọi tới Laravel API
|--------------------------------------------------------------------------
*/

// 🎵 Nhạc
Route::post('/songs/upload', [SongController::class, 'upload']);
Route::get('/songs', [SongController::class, 'index']);

// 👤 Hồ sơ người dùng
Route::prefix('profiles')->group(function () {
    Route::post('/save', [ProfileController::class, 'save']);       // Lưu hoặc cập nhật (auto create nếu chưa có)
    Route::get('/{user_id}', [ProfileController::class, 'show']);   // Lấy theo Firebase user_id
    Route::put('/{id}', [ProfileController::class, 'update']);      // Cập nhật theo id (tùy chọn)
});
