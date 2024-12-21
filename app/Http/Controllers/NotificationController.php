<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Notification;
use Illuminate\Support\Facades\Auth;
use App\Events\SendNotification;

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
            return response()->json(['success' => true]);
        } else {
            return response()->json(['success' => false], 404);
        }
    }

    public function getNotification($id){
        $notification = Notification::find($id);
        if($notification){
            return response()->json($notification);
        } else {
            return response()->json(['error' => 'Notification not found.'], 404);
        }
    }
}