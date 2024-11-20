<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\View\View;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\RedirectResponse;

use App\Models\User;

class UserProfileController extends Controller
{
    public function showProfile(): View|RedirectResponse
    {
        // Get the currently authenticated user
        $user = Auth::user();

        // Check if the user is authenticated
        if (!$user) {
            return redirect()->route('login')->withErrors('You must be logged in to view your profile.');
        }

        // Return the profile view with the user data
        return view('pages.showprofile', ['user' => $user]);
    }

    public function editProfile(): View
    {
        $user = Auth::user();

        if (!$user) {
            return redirect()->route('login')->withErrors('You must be logged in to edit your profile.');
        }

        return view('pages.editprofile', ['user' => $user]);
    }

    public function updateProfile(Request $request): RedirectResponse
    {
        $user = Auth::user();

        if (!$user) {
            return redirect()->route('login')->withErrors('You must be logged in to edit your profile.');
        }

        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users,username,' . $user->id,
            'bio' => 'nullable|string|max:1000',
        ]);

        $user->update($validatedData);

        return redirect()->route('profile.show')->with('success', 'Profile updated successfully!');
    }
}
