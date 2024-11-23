@extends('layouts.app')

@section('content')
<div class="container">
    <h2>Edit Answer</h2>
    <form action="{{ route('answers.update', $answer->id) }}" method="POST">
        @csrf
        @method('PUT')
        <div class="form-group">
            <label for="answer">Answer</label>
            <textarea class="form-control" id="answer" name="content" rows="5">{{ old('content', $answer->content) }}</textarea>
        </div>
        <button type="submit" class="btn btn-primary">Update Answer</button>
        <a href="{{ route('questions.show', $question->id) }}" class="btn btn-secondary">Cancel</a>
    </form>
</div>
@endsection