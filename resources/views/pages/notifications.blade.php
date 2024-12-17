@extends('layouts.app')

@section('title', 'Notifications')

@section('content')
<div class="container my-4">
    <h1 class="mb-4">Notifications</h1>

    @foreach($notifications as $notification)
        <div class="card mb-3 {{ $notification->viewed ? 'bg-light' : 'bg-white' }}">
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
                <form action="{{ route('notifications.read', $notification->id) }}" method="POST" class="d-inline">
                    @csrf
                    <button type="submit" class="btn btn-sm {{ $notification->viewed ? 'btn-secondary' : 'btn-primary' }}">
                        {{ $notification->viewed ? 'Mark as Unread' : 'Mark as Read' }}
                    </button>
                </form>
            </div>
        </div>
    @endforeach
</div>
@endsection