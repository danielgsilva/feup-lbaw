@extends('layouts.app')

@section('title', $question->title)

<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

@section('content')
<div class="container my-4 answer-section">
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
            @if (Auth::check() && Auth::id() !== $question->id_user)
                 <a href="{{ route('report.create', ['type' => 'question', 'id' => $question->id]) }}" class="btn btn-danger btn-sm">Report Question</a>
             @endif
            <div>
            <button id="like-button" class="btn btn-outline-success btn-sm me-2 
                @if($userVote == 1) bg-success text-white @endif" onclick="voteq({{ $question->id }}, 1)">
                <i class="bi bi-hand-thumbs-up"></i> Like
            </button>
            <button id="dislike-button" class="btn btn-outline-danger btn-sm 
                @if($userVote == -1) bg-danger text-white @endif" onclick="voteq({{ $question->id }}, -1)">
                <i class="bi bi-hand-thumbs-down"></i> Dislike
            </button>
            <span class="badge bg-secondary ms-2" id="vote">Votes: {{ $question->votes }}</span>

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
                .then(response => {
                    if (response.status === 401) {
                        // Redirecionar para a página de login
                        return response.json().then(data => {
                            window.location.href = data.redirect;
                        });
                    }
                    return response.json();
                })
                .then(data => {
                    // Update the vote count
                    document.querySelector('#vote').textContent = `Votes: ${data.votes}`;
                    
                    // Highlight buttons based on user vote
                    if (data.userVote === 1) {
                        document.getElementById('like-button').classList.add('bg-success', 'text-white');
                        document.getElementById('dislike-button').classList.remove('bg-danger', 'text-white');
                        document.getElementById('like-button').setAttribute('onclick', `voteq(${questionId}, 0)`);
                        document.getElementById('dislike-button').setAttribute('onclick', `voteq(${questionId}, -1)`);
                    } else if (data.userVote === -1) {
                        document.getElementById('like-button').classList.remove('bg-success', 'text-white');
                        document.getElementById('dislike-button').classList.add('bg-danger', 'text-white');
                        document.getElementById('like-button').setAttribute('onclick', `voteq(${questionId}, 1)`);
                        document.getElementById('dislike-button').setAttribute('onclick', `voteq(${questionId}, 0)`);
                    } else {
                        document.getElementById('like-button').classList.remove('bg-success', 'text-white');
                        document.getElementById('dislike-button').classList.remove('bg-danger', 'text-white');
                        document.getElementById('like-button').setAttribute('onclick', `voteq(${questionId}, 1)`);
                        document.getElementById('dislike-button').setAttribute('onclick', `voteq(${questionId}, -1)`);
                    }
                });
            }
            </script>

            </div>
        </div>
    </div>

    <!-- Question Actions -->
    @if ((Auth::check() && Auth::id() === $question->id_user) || (Auth::check() && Auth::user()->admin))
        <div class="d-flex mb-4 gap-2">
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
    <button id="toggle-comment-form" class="btn btn-secondary mb-3">Add Your Comment</button>
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

    <!-- Add Comment Button and Form -->
    <div id="comment-form" style="display: none;" class="mb-4">
        <form action="{{ route('comments.store') }}" method="POST">
            @csrf
            <input type="hidden" name="id_question" value="{{ $question->id }}">
            <div class="mb-3">
                <label for="comment-content" class="form-label">Your Comment:</label>
                <textarea id="comment-content" name="content" class="form-control" rows="2" required></textarea>
            </div>
            <button type="submit" class="btn btn-success">Submit Comment</button>
        </form>
    </div>

    <!-- Answers Section -->
    @if(request('show') === 'comments')
        <h3 class="mb-3">Comments</h3>
    @else
        <h3 class="mb-3">Answers</h3>
    @endif
    @if(request('show') !== 'comments')
        <button id="toggle-order" class="btn btn-outline-secondary mb-3" data-order="{{ $order }}">
            Order by {{ $order === 'votes' ? 'Date' : 'Votes' }}
        </button>
    @endif
    <a href="{{ request()->fullUrlWithQuery(['show' => request('show') === 'comments' ? 'answers' : 'comments']) }}" class="btn btn-outline-secondary mb-3">
        Show {{ request('show') === 'comments' ? 'Answers' : 'Comments' }}
    </a>

    @if(request('show') === 'comments')
        <div id="comments-section">
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
        </div>
    @else
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
                        <a href="{{ route('answers.comments', $answer->id)}}" class="btn btn-outline-secondary btn-sm ms-2">Comments: {{ $answer->comments->count() }}</a>
                    </div>
                    @if (Auth::check() && Auth::id() !== $question->id_user)
                        <a href="{{ route('report.create', ['type' => 'answer', 'id' => $answer->id]) }}" class="btn btn-danger btn-sm">Report Answer</a>
                    @endif
                    <div>
                    <button 
                        id="like-answer-{{ $answer->id }}" 
                        class="btn btn-outline-success btn-sm me-2"
                        onclick="votea({{ $answer->id }}, 1)">
                        <i class="bi bi-hand-thumbs-up"></i> Like
                    </button>
                    <button 
                        id="dislike-answer-{{ $answer->id }}" 
                        class="btn btn-outline-danger btn-sm "
                        onclick="votea({{ $answer->id }}, -1)">
                        <i class="bi bi-hand-thumbs-down"></i> Dislike
                    </button>
                    <span class="badge bg-secondary ms-2 mt-2">Votes: {{ $answer->votes }}</span>

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
                        .then(response => {
                            if (response.status === 401) {
                                // Redirecionar para a página de login
                                return response.json().then(data => {
                                    window.location.href = data.redirect;
                                });
                            }
                            return response.json();
                        })
                        .then(data => {
                            // Update the vote count
                            const voteBadge = document.querySelector(`#answer-${answerId} .badge`);
                            voteBadge.textContent = `Votes: ${data.votes}`;

                            // Toggle button styles based on the user's current vote
                            const likeButton = document.getElementById(`like-answer-${answerId}`);
                            const dislikeButton = document.getElementById(`dislike-answer-${answerId}`);

                            if (data.userVote === 1) {
                                document.getElementById(`like-answer-${answerId}`).classList.add('bg-success', 'text-white');
                                document.getElementById(`dislike-answer-${answerId}`).classList.remove('bg-danger', 'text-white');
                                document.getElementById(`like-answer-${answerId}`).setAttribute('onclick', `votea(${answerId}, 0)`);
                                document.getElementById(`dislike-answer-${answerId}`).setAttribute('onclick', `votea(${answerId}, -1)`);

                            } else if (data.userVote === -1) {
                                document.getElementById(`like-answer-${answerId}`).classList.remove('bg-success', 'text-white');
                                document.getElementById(`dislike-answer-${answerId}`).classList.add('bg-danger', 'text-white');
                                document.getElementById(`like-answer-${answerId}`).setAttribute('onclick', `votea(${answerId}, 1)`);
                                document.getElementById(`dislike-answer-${answerId}`).setAttribute('onclick', `votea(${answerId}, 0)`);
                            } else {
                                document.getElementById(`like-answer-${answerId}`).classList.remove('bg-success', 'text-white');
                                document.getElementById(`dislike-answer-${answerId}`).classList.remove('bg-danger', 'text-white');
                                document.getElementById(`like-answer-${answerId}`).setAttribute('onclick', `votea(${answerId}, 1)`);
                                document.getElementById(`dislike-answer-${answerId}`).setAttribute('onclick', `votea(${answerId}, -1)`);
                            }
                        });
                    }
                </script>

                    </div>
                </div>
            </div>
        <div class="mb-4">
            @if ((Auth::check() && Auth::id() === $answer->id_user) || (Auth::check() && Auth::user()->admin))
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
    @endif

    <div class="mt-4">
        @if(request('show') === 'comments')
            {{ $comments->appends(['order' => $order, 'show' => 'comments'])->links('pagination::bootstrap-4') }}
        @else
            {{ $answers->appends(['order' => $order, 'show' => 'answers'])->links('pagination::bootstrap-4') }}
        @endif
    </div>
</div>
@endsection
