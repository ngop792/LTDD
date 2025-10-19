<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('profiles', function (Blueprint $table) {
            $table->id();
            
            // ⚙️ Giữ user_id là string (dễ dùng cho Supabase hoặc tạm user)
            $table->string('user_id', 100)->nullable()->index();

            $table->string('name', 100)->nullable();
            $table->string('avatar_url', 255)->nullable();
            $table->text('bio')->nullable();

            // Các chỉ số khác (nếu bạn cần)
            $table->integer('followers_count')->default(0);
            $table->integer('following_count')->default(0);

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('profiles');
    }
};
