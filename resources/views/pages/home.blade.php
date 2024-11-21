@extends('layouts.app')

@section('title', 'Home')

@section('content')
<section id="home">
    <h1>Welcome to the Home Page</h1>
</section>
@endsection
@section('questions')
<section id="questions">
    <h2>Questions</h2>
    <ul>
        @foreach($questions as $question)
            <li>{{ $question->title }}</li>
        @endforeach
    </ul>
</section>
@endsection