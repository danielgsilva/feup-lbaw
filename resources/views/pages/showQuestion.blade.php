
@extends('layouts.app')

@section('title', $question->title)

@section('content')
<div class="container">
    <div class ="card">
    <h1>{{ $question->title }}</h1>
    <p>{{ $question->content }}</p>
    <div class="question-meta">
        <span>
            Asked by: 
            @if ($question->user)
            <a href="{{ route('profile.show', $question->user->username) }}">{{ $question->user->name }}</a> on {{ $question->date }}
            @else
            Anonymous on {{ $question->date }}
            @endif
        </span>
        <span>Votes: {{ $question->votes }}</span>
    </div>
    </div>
    @if (Auth::check() && Auth::id() === $question->id_user)
    <a href="{{ route('questions.edit', $question->id) }}" class="btn btn-primary">
        <button type="button" class="btn btn-primary">Edit Question</button>
    </a>
    <form action="{{ route('questions.destroy', $question->id) }}" method="POST" style="display:inline;">
                @csrf
                @method('DELETE')
                <button type="submit" class="btn btn-danger">Delete</button>
        </form>
    @endif

    @if (Auth::user()->id != $question->id_user)
    <button id="toggle-answer-form" class="btn btn-primary mt-3">Add Your Answer</button>
    @endif
    
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
    <button id="toggle-order" class="btn" data-order="{{ $order }}"> Order by {{ $order === 'votes' ? 'Date' : 'Votes' }} </button>
    @foreach($answers as $answer)
        <div class="answer" id="answer-{{ $answer->id }}">
            <p>{{ $answer->content }}</p>
            <div class="answer-meta">
                <span>Answered by: <a href="{{ route('profile.show', $answer->user->username) }}">{{ $answer->user->name }}</a> on {{ $answer->date }}</span>
                <span>Votes: {{ $answer->votes }}</span>
                @if (Auth::check() && Auth::id() === $answer->id_user)
                <a href="{{ route('answers.edit', $answer->id) }}" class="btn btn-primary">
        <button type="button" class="btn btn-primary">Edit</button>
    </a>
                <form action="{{ route('answers.destroy', $answer->id) }}" method="POST" style="display:inline;">
                    @csrf
                    @method('DELETE')
                    <button type="submit" class="btn btn-danger">Delete</button>
                </form>
                @endif
            </div>
        </div>
    @endforeach
    <div class = "pagination">
        {{$answers->appends(['order' => $order])->links() }}
    </div>

    
</div>
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

