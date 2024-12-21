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

            <!-- Tag filter dropdown with checkboxes for better UX -->
            <div class="dropdown d-flex align-items-center">
                <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="tagDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                    Filter by Tags
                </button>
                <div class="dropdown-menu p-0" aria-labelledby="tagDropdown" style="min-width: unset; padding: 0;">
                    <form id="tag-filter-form" method="get" action="{{ route('home') }}" class="p-2">
                        <!-- Include the current order so it stays consistent in the URL -->
                        <input type="hidden" name="order" value="{{ $order }}">

                        <!-- Tags filter section with checkboxes -->
                        <div class="d-flex flex-wrap">
                            @foreach ($tags as $tag)
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="tag_id[]" value="{{ $tag->id }}" 
                                        id="tag-{{ $tag->id }}" 
                                        {{ in_array($tag->id, $tagIds) ? 'checked' : '' }}>
                                    <label class="form-check-label" for="tag-{{ $tag->id }}">
                                        {{ $tag->name }}
                                    </label>
                                </div>
                            @endforeach
                        </div>

                        <!-- Search button to submit the form -->
                        <button type="submit" class="btn btn-primary btn-sm mt-2">Search</button>
                    </form>
                </div>
            </div>

    </div>

    @if($questions->isEmpty())
        <div class="alert alert-warning mt-4">
            No questions found matching the selected tags.
        </div>
    @else
        @foreach($questions as $question)
            @include('partials.question', ['question' => $question])
        @endforeach
    @endif

    <div class="d-flex justify-content-center mt-4">
        {{ $questions->appends(['order' => $order, 'tag_id' => $tagIds])->links('pagination::bootstrap-4') }}
    </div>
</section>
@endsection

@include('partials.notificationToast')
