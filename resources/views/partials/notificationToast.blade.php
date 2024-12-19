@if(isset($unreadNotifications) && $unreadNotifications->count() > 0)
<div class="notification-toast toast-container position-fixed bottom-0 end-0 p-2">
    @foreach($unreadNotifications->take(2) as $notification)
    <div class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-header"></div>
            <strong class="me-auto">Notification</strong>
            <small class="text-muted">{{ \Carbon\Carbon::parse($notification->date)->format('M d, Y H:i') }}</small>
            <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
        <div class="toast-body">
            <form id="mark-as-read-{{ $notification->id }}" action="{{ route('notifications.read', $notification->id) }}" method="POST" style="display: none;">
                @csrf
            </form>
            @if($notification->id_answer)
                <a href="{{ route('questions.show', ['id' => $notification->answer->id_question, 'order' => 'date']) }}" class="text-decoration-none" onclick="event.preventDefault(); markAsReadAndRedirect({{ $notification->id }}, '{{ route('questions.show', ['id' => $notification->answer->id_question, 'order' => 'date']) }}');">
                    You have a new answer on your question: {{ $notification->answer->question->title ?? 'Unknown Question' }}
                </a>
                <p>Answer: {{ $notification->answer->content }}</p>
            @elseif($notification->id_question_vote)
                <a href="{{ route('questions.show', ['id' => optional($notification->getQuestionFromVote())->id, 'order' => 'date']) }}" class="text-decoration-none" onclick="event.preventDefault(); markAsReadAndRedirect({{ $notification->id }}, '{{ route('questions.show', ['id' => optional($notification->getQuestionFromVote())->id, 'order' => 'date']) }}');">
                    Your question received a new vote: {{ optional($notification->getQuestionFromVote())->title ?? 'Unknown Question' }}
                </a>
            @elseif($notification->id_answer_vote)
                <a href="{{ route('questions.show', ['id' => optional($notification->getAnswerFromVote())->question_id, 'order' => 'date']) }}" class="text-decoration-none" onclick="event.preventDefault(); markAsReadAndRedirect({{ $notification->id }}, '{{ route('questions.show', ['id' => optional($notification->getAnswerFromVote())->question_id, 'order' => 'date']) }}');">
                    Your answer received a new vote on: {{ optional($notification->getAnswerFromVote())->question_title ?? 'Unknown Question' }}
                </a>
                <p>Answer: {{ optional($notification->getAnswerFromVote())->content }}</p>
            @elseif($notification->id_comment)
                @if($notification->comment->id_answer)
                    <a href="{{ url('answers/' . $notification->comment->id_answer . '/comments') }}" class="text-decoration-none" onclick="event.preventDefault(); markAsReadAndRedirect({{ $notification->id }}, '{{ url('answers/' . $notification->comment->id_answer . '/comments') }}');">
                        You have a new comment on your answer: {{ $notification->comment->answer->question->title ?? 'Unknown Question' }}
                    </a>
                    <p>Comment: {{ $notification->comment->content }}</p>
                @elseif($notification->comment->id_question)
                    <a href="{{ route('questions.show', ['id' => $notification->comment->id_question, 'order' => 'date']) }}" class="text-decoration-none" onclick="event.preventDefault(); markAsReadAndRedirect({{ $notification->id }}, '{{ route('questions.show', ['id' => $notification->comment->id_question, 'order' => 'date']) }}');">
                        You have a new comment on your question: {{ $notification->comment->question->title ?? 'Unknown Question' }}
                    </a>
                    <p>Comment: {{ $notification->comment->content }}</p>
                @endif
            @endif
            <button type="button" class="btn btn-sm btn-secondary mt-2" onclick="markAsRead({{ $notification->id }})">Mark as Read</button>
        </div>
    </div>
    @endforeach
</div>
@endif

<script>
function markAsReadAndRedirect(notificationId, url) {
    const form = document.getElementById('mark-as-read-' + notificationId);
    const formData = new FormData(form);

    fetch(form.action, {
        method: 'POST',
        body: formData,
    }).then(response => {
        if (response.ok) {
            window.location.href = url;
        } else {
            console.error('Failed to mark notification as read.');
        }
    }).catch(error => {
        console.error('Error:', error);
    });
}

function markAsRead(notificationId) {
    const form = document.getElementById('mark-as-read-' + notificationId);
    const formData = new FormData(form);

    fetch(form.action, {
        method: 'POST',
        body: formData,
    }).then(response => {
        if (response.ok) {
            console.log('Notification marked as read.');
        } else {
            console.error('Failed to mark notification as read.');
        }
    }).catch(error => {
        console.error('Error:', error);
    });
}
</script>