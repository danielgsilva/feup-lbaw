<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Models\Notification;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class ShareUnreadNotifications
{

    public function handle(Request $request, Closure $next)
    {
        if (Auth::check()) {
            $unreadNotifications = Notification::where('id_user', Auth::id())
                ->where('viewed', false)
                ->orderBy('date', 'desc')
                ->get();
            view()->share('unreadNotifications', $unreadNotifications);
        }

        return $next($request);
    }
}
