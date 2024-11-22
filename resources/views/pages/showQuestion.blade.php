@extends('layouts.app')

@section('title', $question->title)

@section('content')
<div class="container">
    <h1>{{ $question->title }}</h1>
    <p>{{ $question->content }}</p>
    <div class="question-meta">
        <span>Asked by: {{ $question->user->name }} on {{ $question->date }}</span>
    </div>
    <div class="question-votes">
        <span>Votes: {{ $question->votes }}</span>
    </div>

    <button id="toggle-answer-form" class="btn btn-primary mt-3">Add Your Answer</button>

    <!-- Hidden Answer Form -->
    <div id="answer-form" style="display: none;" class="mt-3">
        <form action="{{ route('answers.store') }}" method="POST">
            @csrf
            <input type="hidden" name="id_question" value="{{ $question->id }}">

            <div class="form-group">
                <label for="content">Your Answer:</label>
                <textarea id="content" name="content" class="form-control" rows="4" required></textarea>
            </div>

            <button type="submit" class="btn btn-success mt-2">Submit Answer</button>
        </form>
    </div>

    <div class="question-answers">
        <h3>Answers</h3>
        @foreach($answers as $answer)
            <div class="answer">
            <a href="{{ route('home', ['id' => $answer->id]) }}">{{ $answer->content }}</a> <!-- Change link to answer page when implemented -->
                <div class="answer-meta">
                    <span>Answered by: {{ $answer->user->name }} on {{ $answer->date }}</span>
                    <span>Votes: {{ $answer->votes }}</span>
                </div>
            </div>
        
        @endforeach
        <div class="pagination">
            {{ $answers->links() }} <!-- Display pagination links -->
        </div>
    </div>
    <button id="toggle-comments" class="btn btn-primary mt-3">Show Comments</button>
    <div id="comments-section" style="display: none;">
        <h3>Comments</h3>
        @foreach($question->comments as $comment)
            <div class="comment">
                <p>{{ $comment->content }}</p>
                <span>Commented by: {{ $comment->user->name }} on {{ $comment->date }}</span>
            </div>
        @endforeach
    </div>
</div>

<script>
    document.getElementById('toggle-comments').addEventListener('click', function() {
        var commentsSection = document.getElementById('comments-section');
        if (commentsSection.style.display === 'none') {
            commentsSection.style.display = 'block';
            this.textContent = 'Hide Comments';
        } else {
            commentsSection.style.display = 'none';
            this.textContent = 'Show Comments';
        }
    });
</script>

<script>
    // Toggle visibility of the answer form
    document.getElementById('toggle-answer-form').addEventListener('click', function() {
        var answerForm = document.getElementById('answer-form');
        if (answerForm.style.display === 'none') {
            answerForm.style.display = 'block';
        } else {
            answerForm.style.display = 'none';
        }
    });
</script>
@endsection

<!--
Question model:
    protected $fillable = [
            'title',
            'content',
            'date',
            'reports',
            'votes',
            'edited',
            'id_user',
    ];
-->


