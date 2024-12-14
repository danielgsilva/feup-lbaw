@extends('layouts.app')

@section('content')
<div id="profile" class="container">
    <h1>User Profile</h1>

   
    <div class="card profile-card">
        <div class="card-body">
            <h3>{{ $user->name }}</h3>
            <img src="{{ asset('storage/' . $user->image->image_path) }}" alt="profile image">
            <p><strong>Username:</strong> {{ $user->username }}</p>
            <p><strong>Email:</strong> {{ $user->email }}</p>
            <p><strong>Bio:</strong> 
            @if ($user->ban)
            <span class="badge badge-danger">This user is banned</span>
            @else
            {{ $user->bio ?? 'No bio available' }}
            @endif
        </p>
            <p><strong>Score:</strong> {{ $user->score }}</p>
        </div>
    </div>

    
    @if (Auth::check() && ($isOwnProfile || (Auth::user()->admin) && Auth::user()->id !== $user->id) && !Auth::user()->ban)
    <div class="mt-3">
        <a href="{{ route('profile.editAny', ['username' => $user->username]) }}" class="btn btn-primary profile-btn">
            Edit Profile
        </a>
    </div>
@endif

@if (Auth::check() && Auth::user()->admin && $user->username !== 'anonymous' && !$isOwnProfile)
    <div class="mt-3">
        <form action="{{ route('profile.delete', $user->username) }}" method="POST" onsubmit="return confirm('Tem a certeza de que deseja eliminar este utilizador? Esta ação é irreversível.');">
            @csrf
            @method('DELETE')
            <button type="submit" class="btn btn-danger profile-btn">Delete User</button>
        </form>
    </div>
@endif

@if(Auth::check() && Auth::user()->admin && !$isOwnProfile && $user->username !== 'anonymous')
    <form method="POST" action="{{ route('profile.toggleBan', $user->username) }}">
        @csrf
        @method('PATCH')
        <button class="btn {{ $user->ban ? 'btn-danger' : 'btn-success' }} profile-btn">
            {{ $user->ban ? 'Unban user' : 'Ban User' }}
        </button>
    </form>
@endif


    

    <!-- Profile Content in Grid (Questions and Answers side by side) -->
    <div class="row mt-5 profile-content">
        <!-- My Questions Section -->
        <div class="col-md-6">
            <h4>My Questions</h4>
            @forelse ($questions as $question)
                <div class="card mt-3 profile-question-card">
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

        <!-- My Answers Section -->
        <div class="col-md-6">
            <h4>My Answers</h4>
            @forelse ($answers as $answer)
                <div class="card mt-3 profile-answer-card">
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
</div>
@endsection

