@extends('layouts.app')

@section('title', 'Edit Question')

@section('content')

    @section('scripts')
        <script> const tags = @json($tags);</script>
        <script> const max_tags = 5; </script>
        <script> const oldTagsList = @json($question->tags); </script>
    @endsection

<div class="container my-4">
    <div class="card">
        <div class="card-header">
            <h1 class="card-title">Edit Question</h1>
        </div>
        <div class="card-body">
            <form action="{{ route('questions.update', $question->id) }}" method="POST">
                @csrf
                @method('PUT')
                
                <!-- Title Input -->
                <div class="mb-3">
                    <label for="title" class="form-label">Title</label>
                    <input type="text" name="title" id="title" class="form-control" value="{{ $question->title }}" required>
                </div>

                <!-- Body Input -->
                <div class="mb-3">
                    <label for="content" class="form-label">Body</label>
                    <textarea name="content" id="content" class="form-control" rows="5" required>{{ $question->content }}</textarea>
                </div>

                @include('pages.tags')
        
                @include('partials.toast')

                <!-- Submit Button -->
                <button type="submit" class="btn btn-success">Update Question</button>
                <a href="{{ route('questions.show', $question->id) }}" class="btn btn-secondary">Cancel</a>
            </form>
        </div>
    </div>
</div>
@endsection
