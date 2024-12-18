<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Notification;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    public function index()
    {
        $notifications = Notification::where('id_user', Auth::id())
            ->orderBy('date', 'desc')
            ->get();
        
        $unreadNotifications = Notification::where('id_user', Auth::id())
            ->where('viewed', false)
            ->orderBy('date', 'desc')
            ->get();

        return view('pages.notifications', compact('notifications', 'unreadNotifications'));
    }

    public function markAsRead($id)
    {
    $notification = Notification::findOrFail($id);
    $notification->viewed = !$notification->viewed;
    $notification->save();

    session()->flash('notification', 'Notification status updated successfully.');

    return redirect()->back();
    }
}