@extends('layouts.app')

@section('title', 'Notifications')

@section('content')
<div class="container my-4">
    <h1 class="mb-4">Notifications</h1>

    <button id="toggle-notifications" class="btn btn-outline-secondary mb-4">Show Unread Notifications</button>

    <div id="notifications-list">
        @foreach($notifications as $notification)
            <div class="card mb-3 notification-item {{ $notification->viewed ? 'bg-light' : 'bg-white' }}" data-viewed="{{ $notification->viewed }}" data-id="{{ $notification->id }}">
                <div class="card-body">
                    <h5 class="card-title">
                        @if($notification->id_answer)
                            <a href="{{ route('questions.show', ['id' => $notification->answer->id_question, 'order' => 'date']) }}" class="text-decoration-none">
                                You have a new answer on your question.
                            </a>
                        @elseif($notification->id_question_vote)
                            <a href="{{ route('questions.show', ['id' => optional($notification->getQuestionFromVote())->id, 'order' => 'date']) }}" class="text-decoration-none">
                                Your question received a new vote.
                            </a>
                        @elseif($notification->id_answer_vote)
                            <a href="{{ route('questions.show', ['id' => optional($notification->getAnswerFromVote())->question_id, 'order' => 'date']) }}" class="text-decoration-none">
                                Your answer received a new vote.
                            </a>
                        @elseif($notification->id_comment)
                            @if($notification->comment->id_answer)
                                <a href="{{ url('answers/' . $notification->comment->id_answer . '/comments') }}" class="text-decoration-none">
                                    You have a new comment on your answer.
                                </a>
                            @elseif($notification->comment->id_question)
                                <a href="{{ route('questions.show', ['id' => $notification->comment->id_question, 'order' => 'date']) }}" class="text-decoration-none">
                                    You have a new comment on your question.
                                </a>
                            @endif
                        @endif
                    </h5>
                    <p class="card-text">
                        @if($notification->id_answer)
                            New Answer on: {{ $notification->answer->question->title ?? 'Unknown Question' }}
                        @elseif($notification->id_question_vote)
                            New Vote on: {{ optional($notification->getQuestionFromVote())->title ?? 'Unknown Question' }}
                        @elseif($notification->id_answer_vote)
                            New Vote on your Answer to: {{ optional($notification->getAnswerFromVote())->question_title ?? 'Unknown Question' }}
                        @elseif($notification->id_comment)
                            New Comment on: {{ $notification->comment->answer->question->title ?? $notification->comment->question->title ?? 'Unknown Question' }}
                        @endif
                    </p>
                    <small class="text-muted">{{ $notification->date }}</small>
                    <button type="button" class="btn btn-sm {{ $notification->viewed ? 'btn-secondary' : 'btn-primary' }}" onclick="markAsRead({{ $notification->id }}, this)">
                        {{ $notification->viewed ? 'Mark as Unread' : 'Mark as Read' }}
                    </button>
                </div>
            </div>
        @endforeach
    </div>
</div>

<script>
document.getElementById('toggle-notifications').addEventListener('click', function() {
    const notifications = document.querySelectorAll('.notification-item');
    const showUnread = this.textContent.includes('Unread');
    notifications.forEach(notification => {
        if (showUnread) {
            if (notification.dataset.viewed === '1') {
                notification.style.display = 'none';
            }
        } else {
            notification.style.display = 'block';
        }
    });
    this.textContent = showUnread ? 'Show All Notifications' : 'Show Unread Notifications';
});

function markAsRead(notificationId, button) {
    fetch(`/notifications/${notificationId}/read`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': '{{ csrf_token() }}'
        },
        body: JSON.stringify({ viewed: button.classList.contains('btn-primary') })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            button.classList.toggle('btn-primary');
            button.classList.toggle('btn-secondary');
            button.textContent = button.classList.contains('btn-primary') ? 'Mark as Read' : 'Mark as Unread';
            const notificationItem = button.closest('.notification-item');
            notificationItem.dataset.viewed = button.classList.contains('btn-primary') ? '0' : '1';
            notificationItem.classList.toggle('bg-white');
            notificationItem.classList.toggle('bg-light');
        } else {
            console.error('Failed to mark notification as read.');
        }
    })
    .catch(error => console.error('Error:', error));
}
</script>
@endsection