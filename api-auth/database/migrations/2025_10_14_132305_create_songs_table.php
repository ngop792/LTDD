<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('songs', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('file_path')->nullable(); // ✅ Cho phép null để tránh lỗi khi không có file
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('songs');
    }
};
