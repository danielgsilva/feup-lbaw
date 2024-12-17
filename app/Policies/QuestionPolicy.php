<?php

namespace App\Policies;

use App\Models\Question;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

class QuestionPolicy
{
    public function create(User $user): bool
    {
        return Auth::check();
    }
    public function update(User $user, Question $question): bool
    {
        return Auth::check() && $user->id === $question->id_user || $user->admin;
    }

    public function delete(User $user, Question $question): bool
    {
        return Auth::check() && $user->id === $question->id_user || $user->admin;
    }
}