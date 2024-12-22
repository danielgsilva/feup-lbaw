@extends('layouts.app')

@section('title', $question->title)

<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

@section('content')
<div class="container my-4 answer-section">
    <div class="card mx-auto my-4" style="max-width: 900px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
        <div class="card-body">
            <div class="d-flex justify-content-between">
               
                <div>
                    <h1 class="card-title" style="display: inline;">
                        {{ $question->title }}
                    </h1>
                    @if ($question->edited)
                        
                        <span class="badge bg-light text-muted ms-2" style="font-size: 0.8rem; vertical-align: middle;"><i>(Edited)</i></span>
                    @endif
                </div>

                
                <div class="dropdown">
                    <button class="btn btn-light btn-sm" type="button" id="questionActionsDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="bi bi-three-dots-vertical"></i>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="questionActionsDropdown">
                        @if ((Auth::check() && Auth::id() !== $question->id_user) || (Auth::check() && Auth::user()->admin))
                            <li>
                                <a class="dropdown-item text-dark" href="{{ route('report.create', ['type' => 'question', 'id' => $question->id]) }}">Report Question</a>
                            </li>
                        @endif
                        @if ((Auth::check() && Auth::id() === $question->id_user) || (Auth::check() && Auth::user()->admin))
                            <li>
                                <a class="dropdown-item text-dark" href="{{ route('questions.edit', $question->id) }}">Edit Question</a>
                            </li>
                            <li>
                                <form action="{{ route('questions.destroy', $question->id) }}" method="POST" onsubmit="return confirm('Are you sure you want to delete this question?');">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="dropdown-item text-dark">Delete Question</button>
                                </form>
                            </li>
                        @endif
                    </ul>
                </div>
            </div>

            
            <div class="mt-4 mb-3">
                <strong>Asked by: </strong>
                @if ($question->user)
                    <a href="{{ route('profile.show', $question->user->username) }}" style="text-decoration: none;">{{ $question->user->name }}</a>
                    <strong> on {{ $question->date }} </strong>
                @else
                    Anonymous on {{ $question->date }}
                @endif
            </div>

            <hr class="my-4 shadow-sm" style="border: none; height: 4px; background-color: #000;">
            
            <div class="border rounded p-3 mt-3" style="white-space: pre-wrap;">
                <p class="card-text m-0 p-0">{{ $question->content }}</p>
            </div>



            
            <div class="mt-5" style="margin-top: 1.5rem;">
                <div class="d-flex justify-content-between align-items-center">
                    
                    <div class="d-flex flex-wrap">
                        @if($question->tags)
                            @foreach($question->tags as $tag)
                                <span class="badge bg-primary me-1 fs-6">{{ $tag->name }}</span>
                            @endforeach
                        @endif
                    </div>

                    
                    <div class="d-flex align-items-center">
                        <button id="like-button" class="btn btn-outline-success btn-sm me-2" onclick="voteq({{ $question->id }}, 1)">
                            <i class="bi bi-hand-thumbs-up"></i> Like
                        </button>
                        <button id="dislike-button" class="btn btn-outline-danger btn-sm" onclick="voteq({{ $question->id }}, -1)">
                            <i class="bi bi-hand-thumbs-down"></i> Dislike
                        </button>
                        <span class="badge bg-secondary ms-2" id="vote">Votes: {{ $question->votes }}</span>
                    </div>
                </div>
            </div>

            <script>
                document.addEventListener('DOMContentLoaded', function() {
                    fetchVoteStatus({{ $question->id }});
                });

                function fetchVoteStatus(questionId) {
                    fetch(`/questions/${questionId}/getVote`)
                        .then(response => response.json())
                        .then(data => {
                            const likeButton = document.getElementById('like-button');
                            const dislikeButton = document.getElementById('dislike-button');

                            if (data.userVote === 1) {
                                likeButton.classList.add('bg-success', 'text-white');
                                dislikeButton.classList.remove('bg-danger', 'text-white');
                                likeButton.setAttribute('onclick', `voteq(${questionId}, 0)`);
                                dislikeButton.setAttribute('onclick', `voteq(${questionId}, -1)`);
                            } else if (data.userVote === -1) {
                                likeButton.classList.remove('bg-success', 'text-white');
                                dislikeButton.classList.add('bg-danger', 'text-white');
                                likeButton.setAttribute('onclick', `voteq(${questionId}, 1)`);
                                dislikeButton.setAttribute('onclick', `voteq(${questionId}, 0)`);
                            } else {
                                likeButton.classList.remove('bg-success', 'text-white');
                                dislikeButton.classList.remove('bg-danger', 'text-white');
                                likeButton.setAttribute('onclick', `voteq(${questionId}, 1)`);
                                dislikeButton.setAttribute('onclick', `voteq(${questionId}, -1)`);
                            }
                        });
                }

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
                            
                            return response.json().then(data => {
                                window.location.href = data.redirect;
                            });
                        }
                        return response.json();
                    })
                    .then(data => {
                        
                        document.querySelector('#vote').textContent = `Votes: ${data.votes}`;
                        
                        
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


    @if ($errors->any())
        <div class="alert alert-danger">
            <ul class="mb-0">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif


    <div class="container mt-3 mb-5" style="max-width: 900px;">
  
            <div class="row mb-3">
                <div class="col">
                    <button id="toggle-answer-form" class="btn btn-primary">Add Your Answer</button>
                    <button id="toggle-comment-form" class="btn btn-secondary ml-2">Add Your Comment</button>
                </div>
            </div>
   
            <div id="answer-form" style="display: none;">
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

            <div id="comment-form" style="display: none;">
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
    </div>

    <div id="section-wrapper" class="mb-4 border shadow-sm mt-5">
        <div class="p-3">
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
                    <div class="card mb-3 shadow-sm border" id="comment-{{ $comment->id }}" style="width: 100%; max-width: 100%; box-sizing: border-box;">
                        <div class="card-body">
                            <div class="d-flex justify-content-between">
                                <p class="card-text">{{ $comment->content }}</p>
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
                            <hr class="my-3 shadow-sm" style="border: none; height: 3px; background-color: #000;">
                            <div class="d-flex justify-content-between align-items-center text-muted small">
                                <div>
                                    <strong> Commented by: </strong>
                                    <a href="{{ route('profile.show', $comment->user->username) }}" class="text-decoration-none">{{ $comment->user->name }}</a>
                                    <strong> on {{ $comment->date }} </strong>
                                </div>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
            @else
            @foreach($answers as $answer)
            <div class="card mb-3 border-1 shadow-sm mb-2 answer-question-card"  id="answer-{{ $answer->id }}">
                <input type="hidden" class="answer-id" value="{{$answer->id}}">
                <div class="card-body">
                    <div class="d-flex justify-content-between">
                    <div class="d-flex align-items-center flex-grow-1">
                        <p class="card-text m-0">{{ $answer->content }}</p>

                        <div class="accepted-icon-{{$answer->id}} ms-2">
                            @if ($answer->accepted)
                                <i class="fa-solid fa-check"></i>
                            @endif
                        </div>
                    </div>
                       
                        
                        
                        <div class="dropdown">
                            <button class="btn btn-light btn-sm" type="button" id="answerActionsDropdown-{{ $answer->id }}" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bi bi-three-dots-vertical"></i>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="answerActionsDropdown-{{ $answer->id }}">
                                @if ((Auth::check() && Auth::id() !== $answer->id_user) || (Auth::check() && Auth::user()->admin))
                                    <li>
                                        <a class="dropdown-item text-dark" href="{{ route('report.create', ['type' => 'answer', 'id' => $answer->id]) }}">Report Answer</a>
                                    </li>
                                @endif
                                @if ((Auth::check() && Auth::id() === $answer->id_user) || (Auth::check() && Auth::user()->admin))
                                    <li>
                                        <a class="dropdown-item text-dark" href="{{ route('answers.edit', $answer->id) }}">Edit Answer</a>
                                    </li>
                                    <li>
                                        <form action="{{ route('answers.destroy', $answer->id) }}" method="POST" onsubmit="return confirm('Are you sure you want to delete this answer?');">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="dropdown-item text-dark">Delete Answer</button>
                                        </form>
                                    </li>
                                @endif
                                <div>
                                    @can('accept', $answer)
                                        @if ($answer->accepted)
                                            <button class="mark-accepted btn btn-link mark-accepted-{{$answer->id}}" type="submit" style = "text-decoration: none; color: black;">Unmark as accepted</button>
                                        @else
                                            <button class="mark-accepted btn btn-link mark-accepted-{{$answer->id}}" type="submit" style = "text-decoration: none; color: black;">Mark as accepted</button>
                                        @endif
                                    @endcan
                                </div>

                            </ul>
                        </div>
                    </div>

                    <hr class="my-4 shadow-sm" style="border: none; height: 3px; background-color: #000;">

                    <div class="d-flex align-items-center justify-content-between">

                        <div class="d-flex align-items-center text-muted small">
                            <strong class="me-1">Answered by:</strong>
                            <a href="{{ route('profile.show', $answer->user->username) }}" style="text-decoration: none;" class="me-1">{{ $answer->user->name }}</a>
                            <strong>on {{ $answer->date }}</strong>
                        </div>

                        
                        <div class="d-flex align-items-center">
                            <button id="like-answer-{{ $answer->id }}" class="btn btn-outline-success btn-sm me-2" onclick="votea({{ $answer->id }}, 1)">
                                <i class="bi bi-hand-thumbs-up"></i> Like
                            </button>
                            <button id="dislike-answer-{{ $answer->id }}" class="btn btn-outline-danger btn-sm me-2" onclick="votea({{ $answer->id }}, -1)">
                                <i class="bi bi-hand-thumbs-down"></i> Dislike
                            </button>
                            <span class="badge bg-secondary" id="vote-answer-{{ $answer->id }}">Votes: {{ $answer->votes }}</span>
                        </div>

                    </div>
                </div>
            </div>
            @endforeach
            @endif
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const answerCards = document.querySelectorAll('.answer-question-card');
            answerCards.forEach(card => {
                const answerId = card.querySelector('.answer-id').value;
                fetchVoteStatusForAnswer(answerId);
            });
        });

        function fetchVoteStatusForAnswer(answerId) {
            fetch(`/answers/${answerId}/getVote`)
                .then(response => response.json())
                .then(data => {
                    const likeButton = document.getElementById(`like-answer-${answerId}`);
                    const dislikeButton = document.getElementById(`dislike-answer-${answerId}`);
                
                    if (data.userVote === 1) {
                        likeButton.classList.add('bg-success', 'text-white');
                        dislikeButton.classList.remove('bg-danger', 'text-white');
                        likeButton.setAttribute('onclick', `votea(${answerId}, 0)`);
                        dislikeButton.setAttribute('onclick', `votea(${answerId}, -1)`);
                    } else if (data.userVote === -1) {
                        likeButton.classList.remove('bg-success', 'text-white');
                        dislikeButton.classList.add('bg-danger', 'text-white');
                        likeButton.setAttribute('onclick', `votea(${answerId}, 1)`);
                        dislikeButton.setAttribute('onclick', `votea(${answerId}, 0)`);
                    } else {
                        likeButton.classList.remove('bg-success', 'text-white');
                        dislikeButton.classList.remove('bg-danger', 'text-white');
                        likeButton.setAttribute('onclick', `votea(${answerId}, 1)`);
                        dislikeButton.setAttribute('onclick', `votea(${answerId}, -1)`);
                    }
                });
        }

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
                
                document.querySelector(`#vote-answer-${answerId}`).textContent = `Votes: ${data.votes}`;

               
                const likeButton = document.getElementById(`like-answer-${answerId}`);
                const dislikeButton = document.getElementById(`dislike-answer-${answerId}`);
                if (data.userVote === 1) {
                    likeButton.classList.add('bg-success', 'text-white');
                    dislikeButton.classList.remove('bg-danger', 'text-white');
                    likeButton.setAttribute('onclick', `votea(${answerId}, 0)`);
                    dislikeButton.setAttribute('onclick', `votea(${answerId}, -1)`);
                } else if (data.userVote === -1) {
                    likeButton.classList.remove('bg-success', 'text-white');
                    dislikeButton.classList.add('bg-danger', 'text-white');
                    likeButton.setAttribute('onclick', `votea(${answerId}, 1)`);
                    dislikeButton.setAttribute('onclick', `votea(${answerId}, 0)`);
                } else {
                    likeButton.classList.remove('bg-success', 'text-white');
                    dislikeButton.classList.remove('bg-danger', 'text-white');
                    likeButton.setAttribute('onclick', `votea(${answerId}, 1)`);
                    dislikeButton.setAttribute('onclick', `votea(${answerId}, -1)`);
                }
            });
        }
    </script>


    <div class="mt-4">
        @if(request('show') === 'comments')
            {{ $comments->appends(['order' => $order, 'show' => 'comments'])->links('pagination::bootstrap-4') }}
        @else
            {{ $answers->appends(['order' => $order, 'show' => 'answers'])->links('pagination::bootstrap-4') }}
        @endif
    </div>
</div>
@endsection
