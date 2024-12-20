<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Notification;
use App\Events\UserNotification;
use Illuminate\Support\Facades\Auth;
use App\Events\NotificationRead;


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

    public function markAsRead($id, Request $request)
    {
        $notification = Notification::find($id);
        if ($notification) {
            $viewed = $request->input('viewed');
            $notification->viewed = $viewed;
            $notification->save();
            event(new NotificationRead($notification->id, $viewed));
            return response()->json(['success' => true]);
        } else {
            return response()->json(['success' => false], 404);
        }
    }
}