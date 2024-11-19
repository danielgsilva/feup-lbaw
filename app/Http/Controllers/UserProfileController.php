<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use Illuminate\View\View;
use Illuminate\Support\Facades\Auth;

use App\Models\User;

class UserProfileController extends Controller
{
    public function showProfile(): View
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
}
