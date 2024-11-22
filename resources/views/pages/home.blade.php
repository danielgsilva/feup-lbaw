@extends('layouts.app')

@section('title', 'Home')

@section('content')
<section id="home">
    @foreach($questions as $question)
    @include('partials.question', ['question' => $question])
    @endforeach
    <div class="pagination">
    {{ $questions->links() }} <!-- The buttons are huge for some reason, probably css -->
    </div>
</section>
@endsection