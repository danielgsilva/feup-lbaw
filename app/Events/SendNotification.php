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

class SendNotification implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $message;
    public $userId;

    public $questionId; // Should never be null

    public $answerId = null; // Is only not null if the notification is for a vote

    public $vote; // true if it is a vote, false if it is an answer

    public function __construct($message, $userId, $questionId, $answerId, $vote)
    {
        $this->message = $message;
        $this->userId = $userId;
        $this->questionId = $questionId;
        $this->answerId = $answerId;
        $this->vote = $vote;
    }

    public function broadcastOn()
    {
        return new Channel('notifications.' . $this->userId);
    }

    public function broadcastAs()
    {
        return 'notification-received';
    }
}