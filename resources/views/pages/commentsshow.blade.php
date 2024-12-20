@extends('layouts.app')

@section('title', 'Comment Details')

@section('content')

<div class="container my-4">
    <div class="card mb-4">
        <div class="card-header">
            <h1 class="card-title">Comment Content</h1>
        </div>
        <div class="card-body">
            <p class="card-text">{{ $comment->content }}</p>
        </div>
        <div class="card-footer text-muted">
            Posted by: 
            <a href="{{ route('profile.show', $comment->user->username) }}">{{ $comment->user->name }}</a>
            on {{ $comment->created_at }}
        </div>
    </div>
</div>

@endsection
