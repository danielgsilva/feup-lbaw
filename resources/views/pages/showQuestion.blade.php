@extends('layouts.app')

@section('title', $question->title)

<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

@section('content')
<div class="container my-4">
    <!-- Question Card -->
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h1 class="card-title">{{ $question->title }}</h1>
            @if ($question->edited)
                <span class="badge bg-light text-muted ms-2"><i>(Edited)</i></span>
            @endif
        </div>
        <div class="card-body">
            <p class="card-text">{{ $question->content }}</p>
        </div>
        <div class="card-footer d-flex justify-content-between align-items-center text-muted">
            <div>
                Asked by: 
                @if ($question->user)
                    <a href="{{ route('profile.show', $question->user->username) }}">{{ $question->user->name }}</a>
                    on {{ $question->date }}
                @else
                    Anonymous on {{ $question->date }}
                @endif
            </div>
            <div>
            <button class="btn btn-outline-success btn-sm me-2" onclick="voteq({{ $question->id }}, 1)">
                <i class="bi bi-hand-thumbs-up"></i> Like
            </button>
            <button class="btn btn-outline-danger btn-sm" onclick="voteq({{ $question->id }}, -1)">
                <i class="bi bi-hand-thumbs-down"></i> Dislike
            </button>
            <span class="badge bg-secondary ms-2">Votes: {{ $question->votes }}</span>

            <script>
            function voteq(questionId, voteValue) {
                fetch(`/questions/${questionId}/vote`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}'
                    },
                    body: JSON.stringify({ vote: voteValue })
                })
                .then(response => response.json())
                .then(data => {
                    // Optionally, update the UI with the new vote count
                    location.reload();
                });
            }
            </script>

            </div>
        </div>
    </div>

    <!-- Question Actions -->
    @if (Auth::check() && Auth::id() === $question->id_user)
        <div class="mb-4 d-flex gap-2">
            <a href="{{ route('questions.edit', $question->id) }}" class="btn btn-primary">Edit Question</a>
            <form action="{{ route('questions.destroy', $question->id) }}" method="POST" onsubmit="return confirm('Are you sure you want to delete this question?');">
                @csrf
                @method('DELETE')
                <button type="submit" class="btn btn-danger">Delete</button>
            </form>
        </div>
    @endif

    <!-- Error Messages -->
    @if ($errors->any())
        <div class="alert alert-danger">
            <ul class="mb-0">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <!-- Add Answer Button and Form -->
    <button id="toggle-answer-form" class="btn btn-primary mb-3">Add Your Answer</button>
    <div id="answer-form" style="display: none;" class="mb-4">
        <form action="{{ route('answers.store') }}" method="POST">
            @csrf
            <input type="hidden" name="id_question" value="{{ $question->id }}">
            <div class="mb-3">
                <label for="content" class="form-label">Your Answer:</label>
                <textarea id="content" name="content" class="form-control" rows="4" required></textarea>
            </div>
            <button type="submit" class="btn btn-success">Submit Answer</button>
        </form>
    </div>

    <!-- Answers Section -->
    <h3 class="mb-3">Answers</h3>
    <button id="toggle-order" class="btn btn-outline-secondary mb-3" data-order="{{ $order }}">
        Order by {{ $order === 'votes' ? 'Date' : 'Votes' }}
    </button>

    @foreach($answers as $answer)
        <div class="card mb-3" id="answer-{{ $answer->id }}">
            <div class="card-body">
                <p class="card-text">{{ $answer->content }}</p>
            </div>
            <div class="card-footer d-flex justify-content-between align-items-center text-muted">
                <div>
                    Answered by:
                    <a href="{{ route('profile.show', $answer->user->username) }}">{{ $answer->user->name }}</a>
                    on {{ $answer->date }}
                </div>
                <div>
                <button class="btn btn-outline-success btn-sm me-2" onclick="votea({{ $answer->id }}, 1)">
                    <i class="bi bi-hand-thumbs-up"></i> Like
                </button>
                <button class="btn btn-outline-danger btn-sm" onclick="votea({{ $answer->id }}, -1)">
                    <i class="bi bi-hand-thumbs-down"></i> Dislike
                </button>
                <span class="badge bg-secondary ms-2">Votes: {{ $answer->votes }}</span>

                <script>
                function votea(answerId, voteValue) {
                    fetch(`/answers/${answerId}/vote`, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': '{{ csrf_token() }}'
                        },
                        body: JSON.stringify({ vote: voteValue })
                    })
                    .then(response => response.json())
                    .then(data => {
                        // Optionally, update the UI with the new vote count
                        location.reload();
                    });
                }
                </script>

                </div>
            </div>
            @if (Auth::check() && Auth::id() === $answer->id_user)
                <div class="card-footer d-flex gap-2">
                    <a href="{{ route('answers.edit', $answer->id) }}" class="btn btn-primary btn-sm">Edit</a>
                    <form action="{{ route('answers.destroy', $answer->id) }}" method="POST" onsubmit="return confirm('Are you sure you want to delete this answer?');">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                    </form>
                </div>
            @endif
        </div>
    @endforeach

    <!-- Pagination -->
    <div class="mt-4">
        {{ $answers->appends(['order' => $order])->links('pagination::bootstrap-4') }}
    </div>
</div>
@endsection
