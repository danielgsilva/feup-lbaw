@extends('layouts.app')

@section('title', 'Comment Details')

@section('content')

<div class="container my-4">
    <div class="d-flex justify-content-center align-items-center">
        <div class="card mb-4 shadow-sm border" style="background-color: white; width: 80%;">
            <div class="card-body">
            <h1 class="card-title mb-3">Comment Content</h1>
                <p class="card-text">{{ $comment->content }}</p>
                <hr class="my-4 shadow-sm" style="border: none; height: 2px; background-color: #000;">
                <div class="text-muted small">
                    <strong>Commented by:</strong>
                    <a href="{{ route('profile.show', $comment->user->username) }}">{{ $comment->user->name }}</a>
                </div>
            </div>
        </div>
    </div>
</div>

@endsection
