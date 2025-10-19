<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Song;
use Illuminate\Support\Facades\Storage;

class SongController extends Controller
{
    public function upload(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'file' => 'nullable|mimes:mp3,wav,m4a|max:10240', // tối đa 10MB
        ]);

        $filePath = null;

        if ($request->hasFile('file')) {
            $filePath = $request->file('file')->store('songs', 'public');
        }

        $song = Song::create([
            'title' => $request->title,
            'file_path' => $filePath,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Upload thành công',
            'song' => $song,
        ]);
    }

    public function index()
    {
        $songs = Song::all()->map(function ($song) {
            $song->url = $song->file_path ? asset('storage/' . $song->file_path) : null;
            return $song;
        });

        return response()->json([
            'success' => true,
            'songs' => $songs,
        ]);
    }
}
