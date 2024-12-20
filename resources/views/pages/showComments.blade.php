
@extends('layouts.app')

@section('title', 'Comments for Answer')

@section('content')

<div class="container my-4">
    <div class="card mb-4">
        <div class="card-header">
            <h1 class="card-title">Comments for Answer: </h1>
        </div>
        <div class="card-body">
            <p class="card-text">{{ $answer->content }}</p>
        </div>
        <div class="card-footer text-muted">
            Answered by:
            <a href="{{ route('profile.show', $answer->user->username) }}">{{ $answer->user->name }}</a>
            on {{ $answer->date }}
        </div>
    </div>

    <button id="toggle-answer-comment-form" class="btn btn-secondary mb-3">Add Your Comment</button>
    <div id="answer-comment-form" style="display: none;" class="mb-4">
        <form action="{{ route('comments.store') }}" method="POST">
            @csrf
            <input type="hidden" name="id_answer" value="{{ $answer->id }}">
            <div class="mb-3">
                <label for="answer-comment-content" class="form-label">Your Comment:</label>
                <textarea id="answer-comment-content" name="content" class="form-control" rows="2" required></textarea>
            </div>
            <button type="submit" class="btn btn-success">Submit Comment</button>
        </form>
    </div>

    <script>
        document.getElementById('toggle-answer-comment-form').addEventListener('click', function() {
            var form = document.getElementById('answer-comment-form');
            form.style.display = form.style.display === 'none' ? 'block' : 'none';
        });
    </script>

    <h3 class="mb-3">Comments</h3>
    @foreach($comments as $comment)
        <div class="card mb-3" id="comment-{{ $comment->id }}">
            <div class="card-body">
                <p class="card-text">{{ $comment->content }}</p>
            </div>
            <div class="card-footer d-flex justify-content-between align-items-center text-muted">
                <div>
                    Commented by:
                    <a href="{{ route('profile.show', $comment->user->username) }}">{{ $comment->user->name }}</a>
                    on {{ $comment->date }}
                    <a href="{{ route('report.create', ['type' => 'comment', 'id' => $comment->id]) }}" class="btn btn-danger btn-sm">Report Comment</a>
                </div>
            </div>
        </div>
    @endforeach

    <div class="mt-4">
        {{ $comments->links('pagination::bootstrap-4') }}
    </div>
</div>
@endsection