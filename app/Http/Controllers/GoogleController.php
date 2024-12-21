<?php

namespace App\Http\Controllers;

use Laravel\Socialite\Facades\Socialite;
use Illuminate\Support\Facades\Auth;
use App\Models\User;

class GoogleController extends Controller
{
    public function redirect() {
        return Socialite::driver('google')->redirect();
    }

    public function callbackGoogle() {
        $google_user = Socialite::driver('google')->stateless()->user();

        $user = User::where('email', $google_user->getEmail())->first();

        if (!$user) {
            $new_user = User::create([
                'name' => $google_user->getName(),
                'email' => $google_user->getEmail(),
                'google_id' => $google_user->getId(),
                'username' => $google_user->getName(), 
            ]);

            Auth::login($new_user);
        } else {
            
            if (!$user->google_id) {
                $user->google_id = $google_user->getId();
                $user->save();
            }

            Auth::login($user);
        }

       
        return redirect()->intended('home');
    }
}
