@extends('layouts.app')

@section('title', 'Home')

@section('content')
<section id="home">
    
    <div class="create-question-button">
        <a href="{{ route('questions.create') }}" class="btn btn-primary">
            Create New Question
        </a>
    </div>

    <button id="toggle-order-questions" class="btn" data-order="{{ $order }}">
        Order by {{ $order === 'votes' ? 'Date' : 'Votes' }}
    </button>
    
    @foreach($questions as $question)
    @include('partials.question', ['question' => $question])
    @endforeach
    <div class="pagination">
        {{ $questions->appends(['order' => $order])->links() }} <!-- The buttons are huge for some reason, probably css -->
    </div>
</section>
@endsection