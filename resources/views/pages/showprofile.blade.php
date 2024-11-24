@extends('layouts.app')

@section('content')
<div class="container">
    <h1>User Profile</h1>

    <!-- Display the user's information -->
    <div class="card">
        <div class="card-body">
            <h3>{{ $user->name }}</h3>
            <p><strong>Username:</strong> {{ $user->username }}</p>
            <p><strong>Email:</strong> {{ $user->email }}</p>
            <p><strong>Bio:</strong>
            @if ($user->ban)
                <span class="badge badge-danger"> This user is Banned</span> 
            @else
                {{ $user->bio ?? 'No bio available' }}
            @endif
            </p>

            <p><strong>Score:</strong> {{ $user->score }}</p>
        </div>
    </div>

    <!-- Show Edit button only if the profile belongs to the logged-in user -->
    @if ($isOwnProfile && !Auth::user()->ban)
        <div class="mt-3">
            <a href="{{ route('profile.edit') }}" class="btn btn-primary">Edit Profile</a>
        </div>
    @endif

    @if (Auth::check() && Auth::user()->admin && $user->username !== 'anonymous' && Auth::user()->id !== $user->id)
    <div class="mt-3">
        <form action="{{ route('profile.delete', $user->username) }}" method="POST" onsubmit="return confirm('Tem a certeza de que deseja eliminar este utilizador? Esta ação é irreversível.');">
            @csrf
            @method('DELETE')
            <button type="submit" class="btn btn-danger">Eliminar Utilizador</button>
        </form>
    </div>
@endif

@if(Auth::user()->admin && !$isOwnProfile && $user->username !== 'anonymous')
    <form method="POST" action="{{ route('profile.toggleBan', $user->username) }}">
        @csrf
        @method('PATCH')
        <button class="btn {{ $user->ban ? 'btn-danger' : 'btn-success' }}">
            {{ $user->ban ? 'Desbanir Utilizador' : 'Banir Utilizador' }}
        </button>
    </form>
@endif

    <div class="mt-5">
        <h4>My Questions</h4>
        @forelse ($questions as $question)
            <div class="card mt-3">
                <div class="card-body">
                <h5><a href="{{ route('questions.show', $question->id) }}">{{ $question->title }}</a></h5>
                    <p>{{ $question->content }}</p>
                    <p><strong>Votes:</strong> {{ $question->votes }}</p>
                    <p><strong>Posted on:</strong> {{ $question->date }}</p>
                </div>
            </div>
        @empty
            <p>No questions found.</p>
        @endforelse
    </div>

    <!-- Display User's Answers -->
    <div class="mt-5">
        <h4>My Answers</h4>
        @forelse ($answers as $answer)
            <div class="card mt-3">
                <div class="card-body">
                    <p>{{ $answer->content }}</p>
                    <p><strong>Votes:</strong> {{ $answer->votes }}</p>
                    <p><strong>Posted on:</strong> {{ $answer->date }}</p>
                    <p><strong>Answered to:</strong> <a href="{{ route('questions.show', $answer->question->id) }}">{{ $answer->question->title }}</a></p>
                </div>
            </div>
        @empty
            <p>No answers found.</p>
        @endforelse
    </div>
    
</div>
@endsection
