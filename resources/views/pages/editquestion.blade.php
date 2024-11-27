@extends('layouts.app')

@section('content')
<div id="edit-question">
    <h1>Edit Question</h1>
    <form action="{{ route('questions.update', $question->id) }}" method="POST">
        @csrf
        @method('PUT')
        <div class="form-group">
            <label for="title" class="form-label">Title</label>
            <input type="text" name="title" class="form-control" value="{{ $question->title }}">
        </div>
        <div class="form-group">
            <label for="body" class="form-label">Body</label>
            <textarea name="content" class="form-control" rows="5">{{ $question->content }}</textarea>
        </div>
        <button type="submit" class="btn btn-primary">Change Question</button>
    </form>
</div>
@endsection
