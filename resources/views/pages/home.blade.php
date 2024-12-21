@extends('layouts.app')

@section('title', 'Home')

@section('content')
<section id="home" class="container">
    <h2 class="display-4">Featured Questions</h2>

    <div class="create-question-button mb-4">
        <a href="{{ route('questions.create') }}" class="btn btn-primary mt-3">Create New Question</a>
    </div>

    <div class="d-flex mb-4">
        <!-- Order by button -->
        <button id="toggle-order-questions" class="btn btn-outline-secondary mr-2" data-order="{{ $order }}">
            Order by {{ $order === 'votes' ? 'Date' : 'Votes' }}
        </button>

        <!-- Tags dropdown menu -->
        <select id="tag-filter" class="form-control" onchange="window.location.href = this.value;">
            <option value="{{ route('home', ['order' => $order]) }}" {{ !$tagId ? 'selected' : '' }}>All Tags</option>
            @foreach ($tags as $tag)
                <option value="{{ route('home', ['order' => $order, 'tag_id' => $tag->id]) }}" {{ $tag->id == $tagId ? 'selected' : '' }}>
                    {{ $tag->name }}
                </option>
            @endforeach
        </select>
    </div>
    
    @foreach($questions as $question)
        @include('partials.question', ['question' => $question])
    @endforeach
    
    <div class="d-flex justify-content-center mt-4">
        {{ $questions->appends(['order' => $order, 'tag_id' => $tagId])->links('pagination::bootstrap-4') }}
    </div>
</section>
@endsection

