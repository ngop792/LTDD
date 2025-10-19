<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Profile;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    /**
     * 🔹 Lưu hoặc cập nhật hồ sơ người dùng (auto create nếu chưa có)
     */
    public function save(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'nullable|string|max:255',
            'name' => 'nullable|string|max:255',
            'bio' => 'nullable|string|max:500',
            'avatar' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        // Nếu chưa có user_id (guest) → tạo tạm
        $user_id = $validated['user_id'] ?? 'guest_' . Str::random(8);

        // 🔹 Tìm profile theo user_id hoặc tạo mới
        $profile = Profile::firstOrNew(['user_id' => $user_id]);

        // 🔹 Nếu profile mới tạo lần đầu → gán giá trị mặc định
        if (!$profile->exists) {
            $profile->name = 'Vô danh';
            $profile->bio = '';
            $profile->avatar_url = null;
        }

        // 🔹 Cập nhật thông tin nếu có trong request
        if (!empty($validated['name'])) {
            $profile->name = $validated['name'];
        }

        if (!empty($validated['bio'])) {
            $profile->bio = $validated['bio'];
        }

        // 🔹 Cập nhật avatar nếu có upload mới
        if ($request->hasFile('avatar')) {
            // Xóa ảnh cũ nếu tồn tại
            if ($profile->avatar_url && Storage::disk('public')->exists(str_replace('storage/', '', $profile->avatar_url))) {
                Storage::disk('public')->delete(str_replace('storage/', '', $profile->avatar_url));
            }

            $path = $request->file('avatar')->store('avatars', 'public');
            $profile->avatar_url = asset('storage/' . $path);
        }

        $profile->user_id = $user_id;
        $profile->save();

        return response()->json([
            'success' => true,
            'message' => $profile->wasRecentlyCreated
                ? 'Profile created successfully'
                : 'Profile updated successfully',
            'data' => $profile,
        ], 200);
    }

    /**
     * 🔹 Lấy thông tin profile theo user_id
     */
    public function show($user_id)
    {
        $profile = Profile::where('user_id', $user_id)->first();

        // Nếu chưa có thì tự tạo luôn (để lần đầu login không lỗi)
        if (!$profile) {
            $profile = Profile::create([
                'user_id' => $user_id,
                'name' => 'Vô danh',
                'bio' => '',
                'avatar_url' => null,
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $profile,
        ], 200);
    }

    /**
     * 🔹 Cập nhật profile bằng ID (tuỳ chọn)
     */
    public function update(Request $request, $id)
    {
        $profile = Profile::find($id);

        if (!$profile) {
            return response()->json([
                'success' => false,
                'message' => 'Profile not found',
            ], 404);
        }

        $validated = $request->validate([
            'name' => 'nullable|string|max:255',
            'bio' => 'nullable|string|max:500',
            'avatar' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        if (!empty($validated['name'])) $profile->name = $validated['name'];
        if (!empty($validated['bio'])) $profile->bio = $validated['bio'];

        if ($request->hasFile('avatar')) {
            if ($profile->avatar_url && Storage::disk('public')->exists(str_replace('storage/', '', $profile->avatar_url))) {
                Storage::disk('public')->delete(str_replace('storage/', '', $profile->avatar_url));
            }

            $path = $request->file('avatar')->store('avatars', 'public');
            $profile->avatar_url = asset('storage/' . $path);
        }

        $profile->save();

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => $profile,
        ], 200);
    }
}
