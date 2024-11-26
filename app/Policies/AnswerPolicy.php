<?php

namespace App\Policies;

use App\Models\Answer;
use App\Models\User;
use App\Models\Question;
use Illuminate\Support\Facades\Auth;

class AnswerPolicy
{
    public function create(User $user, Question $question): bool
    {
        return Auth::check() && $user->id !== $question->id_user;
    }

    public function update(User $user, Answer $answer): bool
    {
        return Auth::check() && $user->id === $answer->id_user;
    }

    public function delete(User $user, Answer $answer): bool
    {
        return Auth::check() && $user->id === $answer->id_user;
    }

    public function edit(User $user, Answer $answer): bool
    {
        return Auth::check() && $user->id === $answer->id_user;
    }

    public function accept(User $user, Answer $answer): bool
    {
        return Auth::check() && $answer->question->id_user === $user->id;
    }
}