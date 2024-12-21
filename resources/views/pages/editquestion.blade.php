@extends('layouts.app')

@section('title', 'Edit Question')

@section('content')

    @section('scripts')
        <script> const tags = @json($tags);</script>
        <script> const max_tags = 5; </script>
        <script> const oldTagsList = @json($question->tags); </script>
    @endsection

<div class="container vh-100 d-flex justify-content-center align-items-center">
    <div class="row w-100">
        <div class="col-md-6 mx-auto">
            <div class="card p-4 border rounded bg-light shadow-sm" style="max-height: 90vh; overflow-y: auto;">
                
                <h1 class="text-center mb-3">Edit Question</h1>
                <div class="card-body">
                    <form action="{{ route('questions.update', $question->id) }}" method="POST">
                        @csrf
                        @method('PUT')
                        
                        
                        <div class="form-outline mb-4">
                            <label for="title" class="form-label">Title</label>
                            <input type="text" name="title" id="title" class="form-control" value="{{ $question->title }}" required>
                            @if ($errors->has('title'))
                                <span class="text-danger small">
                                    {{ $errors->first('title') }}
                                </span>
                            @endif
                        </div>

                        <!-- Body Input -->
                        <div class="form-outline mb-4">
                            <label for="content" class="form-label">Body</label>
                            <textarea name="content" id="content" class="form-control" rows="5" required>{{ $question->content }}</textarea>
                            @if ($errors->has('content'))
                                <span class="text-danger small">
                                    {{ $errors->first('content') }}
                                </span>
                            @endif
                        </div>

                        @include('pages.tags')

                        @include('partials.toast')

                     
                        <div class="row">
                            <div class="col-6">
                                <button type="submit" class="btn btn-success w-100">Update Question</button>
                            </div>
                            <div class="col-6">
                                <a href="{{ route('questions.show', $question->id) }}" class="btn btn-secondary w-100">Cancel</a>
                            </div>
                        </div>

                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
