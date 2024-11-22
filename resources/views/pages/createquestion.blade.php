@extends('layouts.app')

@section('title', 'Ask a Question')

@section('content')
<section id="ask-question">
    <h1>Ask a Question</h1>

    <!-- Display form validation errors if any -->
    @if ($errors->any())
        <div class="alert alert-danger">
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <!-- Form for creating a new question -->
    <form action="{{ route('questions.store') }}" method="POST">
        @csrf
        <div class="form-group">
            <label for="title">Title:</label>
            <input type="text" name="title" id="title" maxlength="1000" required>
        </div>
        
        <div class="form-group">
            <label for="content">Content:</label>
            <textarea name="content" id="content" rows="10" required></textarea>
        </div>
        
        <button type="submit" class="button">Submit Question</button>
    </form>
</section>
@endsection
