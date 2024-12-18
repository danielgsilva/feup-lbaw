<?php

namespace App\Http\Controllers;

use Laravel\Socialite\Facades\Socialite;
use Illuminate\Support\Facades\Auth;
use App\Models\User;


class GitHubController extends Controller
{
    public function redirect()
    {
        return Socialite::driver('github')->redirect();
    }

    public function callbackGitHub()
    {
        $github_user = Socialite::driver('github')->stateless()->user();
        $user = User::where('github_id', $github_user->getId())->first();

       
        if (!$user) {
     
            $new_user = User::create([
                'name' => $github_user->getName() ?? $github_user->getNickname(),
                'email' => $github_user->getEmail(),
                'github_id' => $github_user->getId(),
                'username' => $github_user->getNickname(),
            ]);

            Auth::login($new_user);
        } else {
            
            Auth::login($user);
        }

        return redirect()->intended('home');
    }
}
