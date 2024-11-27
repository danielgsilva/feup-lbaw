@extends('layouts.app')

@section('content')
<div id="edit-answer">
    <h1>Edit Answer</h1>
    <form action="{{ route('answers.update', $answer->id) }}" method="POST">
        @csrf
        @method('PUT')
        <div class="form-group">
            <label for="content" class="form-label">Answer</label>
            <textarea name="content" class="form-control" rows="5">{{ $answer->content }}</textarea>
        </div>
        <button type="submit" class="btn btn-primary">Change Answer</button>
    </form>
</div>
@endsection