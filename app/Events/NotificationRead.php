<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class NotificationRead implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $message;
    public $notificationId;

    public function __construct($notificationId)
    {
        $this->notificationId = $notificationId;
        $this->message = 'Notification marked as read successfully.';
    }

    public function broadcastOn()
    {
        return new Channel('notifications');
    }

    public function broadcastAs()
    {
        return 'notification-read';
    }
}