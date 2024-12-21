@extends('layouts.app')

@section('title', 'Home')

@section('content')
<section id="home" class="container">
    <h2 class="display-4">Featured Questions</h2>

    <div class="create-question-button mb-4">
        <a href="{{ route('questions.create') }}" class="btn btn-primary mt-3">Create New Question</a>
    </div>

    <button id="toggle-order-questions" class="btn btn-outline-secondary mb-4" data-order="{{ $order }}">
        Order by {{ $order === 'votes' ? 'Date' : 'Votes' }}
    </button>
    
    @foreach($questions as $question)
    @include('partials.question', ['question' => $question])
    @endforeach
    
    <div class="d-flex justify-content-center mt-4">
        {{ $questions->appends(['order' => $order])->links('pagination::bootstrap-4') }}
    </div>
</section>
@endsection

