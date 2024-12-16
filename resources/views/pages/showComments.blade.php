
@extends('layouts.app')

@section('title', 'Comments for Answer')

@section('content')

<div class="container my-4">
    <div class="card mb-4">
        <div class="card-header">
            <h1 class="card-title">Comments for Answer</h1>
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
                </div>
            </div>
        </div>
    @endforeach

    <div class="mt-4">
        {{ $comments->links('pagination::bootstrap-4') }}
    </div>
</div>
@endsection