<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\View\View;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\RedirectResponse;

use App\Models\Tag;
use App\Models\User;
use App\Models\Image;

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

    public function editProfile(string $username = null): View|RedirectResponse
{
    $authUser = Auth::user();

    // Check if the user is logged in
    if (!$authUser) {
        return redirect()->route('login')->withErrors('You must be logged in to edit profiles.');
    }

    // Determine the target user: 
    // - Admins can edit any user profile using the $username parameter.
    // - Non-admins can only edit their own profile.
    if ($username && $authUser->admin) {
        $user = User::where('username', $username)->first();

        if (!$user) {
            return redirect()->route('home')->withErrors('User not found.');
        }
    } else {
        $user = $authUser;
    }

    $tags = Tag::all();

    // Render the edit profile page with the target user
    return view('pages.editprofile', [
        'user' => $user,
        'isAdminEditing' => $username && $authUser->admin,
        'tags' => $tags
    ]);
}

public function updateProfile(Request $request, string $username = null): RedirectResponse
{
    $authUser = Auth::user();

    if (!$authUser) {
        return redirect()->route('login')->withErrors('You must be logged in to update profiles.');
    }

    // Allow admin to update any user's profile
    if ($username && $authUser->admin) {
        $user = User::where('username', $username)->first();

        if (!$user) {
            return redirect()->route('home')->withErrors('User not found.');
        }
    } else {
        $user = $authUser;
    }

    // Validate input
    $validatedData = $request->validate([
        'name' => 'required|string|max:255',
        'username' => 'required|string|max:255|unique:users,username,' . $user->id,
        'bio' => 'nullable|string|max:1000',
        'tagList' => 'max:5',
        'tagList.*' => 'sometimes|distinct|max:100|string',
        'profile_image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
    ]);

    $tags = $request->get('tagList');
    if ($tags != null) {
        $user->tags()->detach();
        foreach ($tags as $tag) {
            $user->tags()->attach($tag);
        }
    }

    // Check if a new profile image is uploaded
    if ($request->hasFile('profile_image')) {
        // Store the new image
        $imagePath = $request->file('profile_image')->store('profile_images', 'public');

        // Update the image path in the Image table
        $image = Image::where('id_user', $user->id)->first();

        if ($image) {
            // If the user already has an image, update it
            $image->update([
                'image_path' => $imagePath,
            ]);
        } else {
            // If the user doesn't have an image, create a new one
            Image::create([
                'image_path' => $imagePath,
                'id_user' => $user->id,
            ]);
        }
    }

    // Update user information excluding the profile_image
    $user->update($validatedData);

    return redirect()->route('profile.show', ['username' => $user->username])
        ->with('success', 'Profile updated successfully!');
}


public function deleteUser(string $username): RedirectResponse
{
    $authuser = Auth::user();


    if (!$authuser) {
        return redirect()->route('home')->withErrors('User not found.');
    }

    
    if ($authuser->username !== $username && !$authuser->admin) {
        return redirect()->route('home')->withErrors('You do not have permission to delete this account.');
    }

    
    $user = User::where('username', $username)->first();

    if (!$user) {
        return redirect()->route('home')->withErrors('User not found.');
    }

    
    if ($authuser->id === $user->id) {
        
        $anonymous = User::firstOrCreate(
            ['username' => 'anonymous'],
            [
                'name' => 'Anonymous',
                'email' => 'anonymous@example.com',
                'bio' => 'This user has been deleted.',
                'score' => 0,
                'password' => bcrypt('anonymous'),
            ]
        );

        
        $user->questions()->update(['id_user' => $anonymous->id]);
        $user->answers()->update(['id_user' => $anonymous->id]);

        
        $user->delete();

        return redirect()->route('home')->with('success', 'Your account has been deleted successfully.');
    }

    
    return redirect()->route('home')->withErrors('You cannot delete this user.');
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

    public function searchUsersPage(): View
    {
        return view('pages.searchusers');
    }


    public function searchUsers(Request $request)
{
    $request->validate([
        'query' => 'required|string|max:255',
    ]);

    $query = $request->input('query');

    
    $users = User::where('name', 'ILIKE', "%$query%")
                 ->orWhere('username', 'ILIKE', "%$query%")
                 ->get();

    
    return response()->json($users);
}

}
