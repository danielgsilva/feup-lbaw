<?php

namespace App\Policies;

use App\Models\Comment;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

class CommentPolicy
{

    public function create(User $user): bool
    {
        return Auth::check();
    }

    public function update(User $user, Comment $comment): bool
    {
        return Auth::check() && ($user->id === $comment->id_user || $user->is_admin);
    }

    public function delete(User $user, Comment $comment): bool
    {
        return Auth::check() && ($user->id === $comment->id_user || $user->is_admin);
    }

    public function view(User $user, Comment $comment): bool
    {
        return true;
    }
}