@extends('layouts.app')

@section('title', 'Ask a Question')

@section('content')
    @section('scripts')
        <script>const tags = @json($tags);</script>
        <script>const max_tags = 5; </script>
    @endsection

<section id="ask-question" class="container my-5">
    <h1 class="mb-4">Ask a Question</h1>

    <!-- Display form validation errors if any -->
    @if ($errors->any())
        <div class="alert alert-danger --bs-danger">
            <ul class="mb-0">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <!-- Form for creating a new question -->
    <form action="{{ route('questions.store') }}" method="POST">
        @csrf
        <div class="mb-3">
            <label for="title" class="form-label">Title:</label>
            <input type="text" name="title" id="title" class="form-control" maxlength="1000" required>
        </div>
        
        <div class="mb-3">
            <label for="content" class="form-label">Content:</label>
            <textarea name="content" id="content" class="form-control" rows="10" required></textarea>
        </div>

        <div class="mb-3 position-relative" >
    
            <label for="questionTagsSelect" class="form-label">Tags</label>

            <div class="d-flex flex-wrap tag-container autocomplete overflow-hidden">
                <input class="form-control autoCompleteTags" id="questionTagsSelect" placeholder="Add up to 5 tags to describe what your question is about. Start typing to see suggestions.">
            </div>

            @if ($errors->has('tagList'))
                <span class="error">
                    Tags must be different and can't be more than 5!
                </span>
            @endif
        </div>
        
        @include('partials.toast')
        
        <button type="submit" class="btn btn-primary">Submit Question</button>
    </form>
</section>
@endsection