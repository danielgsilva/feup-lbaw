<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\View\View;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\RedirectResponse;

use App\Models\User;

class UserProfileController extends Controller
{
    // View a user's profile by username
    public function showProfile(string $username): View|RedirectResponse
    {
        // Find the user by their username
        $user = User::where('username', $username)->first();

        // If the user is not found, redirect to home or show a 404
        if (!$user) {
            return redirect()->route('home')->withErrors('User not found.');
        }

        // Get the currently authenticated user
        $authUser = Auth::user();

        // Check if the authenticated user is viewing their own profile
        $isOwnProfile = $authUser && $authUser->id === $user->id;

        // Return the profile view with the user data and ownership status
        return view('pages.showprofile', [
            'user' => $user,
            'isOwnProfile' => $isOwnProfile,
        ]);
    }

    public function editProfile(): View|RedirectResponse
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

        return redirect()->route('profile.show', ['username' => $user->username])->with('success', 'Profile updated successfully!');
    }
}
