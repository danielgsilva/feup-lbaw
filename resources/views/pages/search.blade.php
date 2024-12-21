@extends('layouts.app')

@section('content')
<div id="search-results" class="d-flex justify-content-center mt-4">
    <div class="w-75"> <!-- Ajuste a largura conforme necessário -->
        <h1 class="text-center mb-4">Search Results for "{{ $search }}"</h1>

        @if ($questions->isEmpty())
            <p class="no-results text-center">No questions found matching your query.</p>
        @else
            <div class="results-list">
                @foreach ($questions as $question)
                    <div class="card mb-3 shadow-sm border" style="width: 100%; max-width: 100%; box-sizing: border-box;">
                        <div class="card-body">
                            <h2>
                                <a href="{{ route('questions.show', $question->id) }}" class="text-decoration-none text-dark">{{ $question->title }}</a>
                            </h2>
                            <p>{{ \Illuminate\Support\Str::limit($question->content, 100) }}</p>
                            <div class="card-meta text-muted small">
                                <span><strong>Asked by: </strong>
                                    <a href="{{ route('profile.show', $question->username) }}" class="text-decoration-none">{{ $question->username }}</a>
                                </span>
                                <span> <strong> on {{ $question->date }} </strong></span>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
            <div class="d-flex justify-content-center mt-4">
                {{ $questions->appends(['query' => $search])->links('pagination::bootstrap-4') }}
            </div>
        @endif
    </div>
</div>
@endsection
