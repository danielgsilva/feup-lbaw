@extends('layouts.app')

@section('content')
<div class="container">
    <h1>Search Results for "{{ $search }}"</h1>

    @if ($questions->isEmpty())
        <p>No questions found matching your query.</p>
    @else
        <ul>
            @foreach ($questions as $question)
            
                    <h2><a href="{{ route('questions.show', $question->id) }}">{{ $question->title }}</a></h2>  
                    <p>{{ \Illuminate\Support\Str::limit($question->content, 100) }}</p>
                    <span> Asked by: 
                            <a href="{{ route('profile.show', $question->username) }}">{{ $question->username }}</a>
                    </span>
                    <span>Asked on {{ $question->date }}</span>
                
            @endforeach
        </ul>
        {{ $questions->appends(['query' => $search])->links() }}
    @endif
</div>
@endsection
