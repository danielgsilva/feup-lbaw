<?php

namespace App\Providers;

use Illuminate\Support\Facades\View;
use Illuminate\Support\ServiceProvider;
use App\Models\Notification;
use Illuminate\Support\Facades\Auth;

class ViewServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot(): void
    {
        View::composer('*', function ($view) {
            if (Auth::check()) {
                $unreadNotifications = Notification::where('id_user', Auth::id())
                    ->where('viewed', false)
                    ->orderBy('date', 'desc')
                    ->get();
                $view->with('unreadNotifications', $unreadNotifications);
            }
        });
    }
}
