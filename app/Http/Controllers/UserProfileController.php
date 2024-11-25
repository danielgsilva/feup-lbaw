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

        // Fetch the user's questions and answers
        $questions = $user->questions; // All questions by this user
        $answers = $user->answers; // All answers by this user

        // Return the profile view with the user data and ownership status
        return view('pages.showprofile', [
            'user' => $user,
            'isOwnProfile' => $isOwnProfile,
            'questions' => $questions,
            'answers' => $answers
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

    public function deleteUser(string $username): RedirectResponse
    {
        $authuser = Auth::user();

        if (!$authuser || !$authuser->admin ) {
            return redirect()->route('home')->withErrors('User not found.');
        }

        $user = User::where('username', $username)->first();

        if (!$user) {
            return redirect()->route('home')->withErrors('User not found.');
        }

        if ($authuser->id === $user->id) {
            return redirect()->route('home')->withErrors('You cannot delete yourself.');
        }

        $anonymous = User::firstorCreate(
            ['username' => 'anonymous',],
            [
            'name' => 'Anonymous',
            'email' => 'anonymous',
            'bio' => 'This user has been deleted.',
            'score' => 0,
            'password' => bcrypt('anonymous'),
        ]);

        $user->questions()->update(['id_user' => $anonymous->id]);
        $user->answers()->update(['id_user' => $anonymous->id]);

        $user->delete();

        return redirect()->route('home')->with('success', 'User deleted successfully.');
    }

    public function toggleBan(string $username): RedirectResponse
    {
        $user = User::where('username', $username)->first();

        if (!Auth::user()->admin ) {
            return redirect()->route('home')->withErrors('User not found.');
        }

        if (!$user) {
            return redirect()->route('home')->withErrors('User not found.');
        }

        if (Auth::user()->id === $user->id) {
            return redirect()->route('home')->withErrors('You cannot ban yourself.');
        }

        $user->ban = !$user->ban;
        $user->save();

        return redirect()->route('profile.show', ['username' => $user->username])->with('success', $user->ban ? 'User banned successfully.' : 'User unbanned successfully.');
    }

    public function search(Request $request): View
    {

        $request->validate([
            'query' => 'required|string|max:255',
        ]);

        $query = $request->input('query');

        $users = User::where('name', 'ILIKE', "%$query%")
            ->orWhere('username', 'ILIKE', "%$query%")
            ->get();

        return view('pages.searchusers', ['users' => $users]);
    }
}
