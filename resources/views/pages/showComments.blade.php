@extends('layouts.app')

@section('title', 'Comments for Answer')

@section('content')

<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<div class="container my-4">
    
    <div class="card mb-4 shadow-sm border" style="background-color: white;">
        <div class="card-body">
            <p class="card-text">{{ $answer->content }}</p>
            
            <hr class="my-4 shadow-sm" style="border: none; height: 2px; background-color: #000;">
            <div class="text-muted small">
                <strong> Answered by: </strong>
                <a href="{{ route('profile.show', $answer->user->username) }}">{{ $answer->user->name }}</a>
                <strong> on {{ $answer->date }} </strong>
            </div>
        </div>
    </div>

    
    <button id="toggle-answer-comment-form" class="btn btn-secondary mb-3">Add Your Comment</button>

    <div id="answer-comment-form" style="display: none;" class="mb-4">
        <form action="{{ route('comments.store') }}" method="POST">
            @csrf
            <input type="hidden" name="id_answer" value="{{ $answer->id }}">
            <div class="mb-3">
                <label for="answer-comment-content" class="form-label">Your Comment:</label>
                <textarea id="answer-comment-content" name="content" class="form-control" rows="2" required placeholder="Write your comment here..."></textarea>
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

    <h3 class="mb-3 mt-3">Comments</h3>
    @foreach($comments as $comment)
    <div class="card mb-3 shadow-sm border" style="background-color: white;" id="comment-{{ $comment->id }}">
        <div class="card-body">
            <div class="d-flex justify-content-between">
                <p class="card-text flex-grow-1">{{ $comment->content }}</p>
                <div class="dropdown">
                    <button class="btn btn-light btn-sm" type="button" id="commentActionsDropdown-{{ $comment->id }}" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="bi bi-three-dots-vertical"></i>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="commentActionsDropdown-{{ $comment->id }}">
                        <li>
                            <a class="dropdown-item text-dark" href="{{ route('report.create', ['type' => 'comment', 'id' => $comment->id]) }}">Report Comment</a>
                        </li>
                    </ul>
                </div>
            </div>
            <hr class="my-3 shadow-sm" style="border: none; height: 2px; background-color: #000;">
            <div class="text-muted small">
                <strong> Commented by: </strong>
                <a href="{{ route('profile.show', $comment->user->username) }}">{{ $comment->user->name }}</a>
                <strong> on {{ $comment->date }} </strong>
            </div>
        </div>
    </div>
@endforeach

    <div class="mt-4">
        {{ $comments->links('pagination::bootstrap-4') }}
    </div>
</div>

@endsection
