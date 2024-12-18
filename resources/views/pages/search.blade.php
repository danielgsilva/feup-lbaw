@extends('layouts.app')

@section('content')
<div id="search-results">
    <h1>Search Results for "{{ $search }}"</h1>

    @if ($questions->isEmpty())
        <p class="no-results">No questions found matching your query.</p>
    @else
        <div class="results-list">
            @foreach ($questions as $question)
                <div class="card">
                    <h2>
                        <a href="{{ route('questions.show', $question->id) }}">{{ $question->title }}</a>
                    </h2>
                    <p>{{ \Illuminate\Support\Str::limit($question->content, 100) }}</p>
                    <div class="card-meta">
                        <span>Asked by: 
                            <a href="{{ route('profile.show', $question->username) }}">{{ $question->username }}</a>
                        </span>
                        <span>on {{ $question->date }}</span>
                    </div>
                </div>
            @endforeach
        </div>
        <div class="d-flex justify-content-center mt-4">
            {{ $questions->appends(['query' => $search])->links('pagination::bootstrap-4') }}
        </div>
    @endif
</div>
@endsection
