<!--@extends('layouts.app')

@section('title', 'Home')

@section('content')
<section id="home" class="container">
    <h2>Featured Questions</h2>

    <div class="create-question-button mb-4">
        <a href="{{ route('questions.create') }}" class="btn create-question-btn">
            Create New Question
        </a>
    </div>

    <button id="toggle-order-questions" class="btn btn-outline-secondary mb-4" data-order="{{ $order }}">
        Order by {{ $order === 'votes' ? 'Date' : 'Votes' }}
    </button>
    
    @foreach($questions as $question)
    @include('partials.question', ['question' => $question])
    @endforeach
    
    <div class="pagination">
        {{ $questions->appends(['order' => $order])->links() }}
    </div>
</section>
@endsection
-->