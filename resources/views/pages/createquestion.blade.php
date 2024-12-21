@extends('layouts.app')

@section('title', 'Ask a Question')

@section('content')
@section('scripts')
    <script>const tags = @json($tags);</script>
    <script>const max_tags = 5; </script>
@endsection

<div class="container vh-100">
    <div class="row justify-content-center align-items-center h-100">
        <div class="col-md-8">
            <section id="ask-question" class="p-4 border rounded bg-light shadow-sm overflow-auto" style="max-height: 90vh;">
                <h1 class="mb-4 text-center">Ask a Question</h1>

                <!-- Display form validation errors if any -->
                @if ($errors->any())
                    <div class="alert alert-danger">
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
                        <input type="text" name="title" id="title" class="form-control" maxlength="1000" placeholder="Enter your question title here" required>
                    </div>
                    
                    <div class="mb-3">
                        <label for="content" class="form-label">Content:</label>
                        <textarea name="content" id="content" class="form-control" rows="10" placeholder="Provide detailed information about your question here" required></textarea>
                    </div>

                    @include('pages.tags')
                    
                    @include('partials.toast')
                    
                    <button type="submit" class="btn btn-primary w-100">Submit Question</button>
                </form>
            </section>
        </div>
    </div>
</div>
@endsection
