@extends('layouts.app')

@section('content')

<div class="container my-5">
    <h1 class="mb-4 text-center">User Profile</h1>

    <div class="card shadow-sm">
        <div class="card-body text-center">
            <h3 class="card-title">{{ $user->name }}</h3>
            
            @if ($user->image)
                <img src="{{ asset('storage/' . $user->image->image_path) }}" 
                     alt="profile image" 
                     class="img-fluid rounded-circle my-3" 
                     style="width: 150px; height: 150px; object-fit: cover;">
            @endif
            
            <p class="mb-1"><strong>Username:</strong> {{ $user->username }}</p>
            <p class="mb-1"><strong>Email:</strong> {{ $user->email }}</p>
            
            <p class="mb-1"><strong>Bio:</strong> 
                @if ($user->ban)
                    <span class="badge badge-danger">This user is banned</span>
                @else
                    {{ $user->bio ?? 'No bio available' }}
                @endif
            </p>
            
            <p class="mb-0"><strong>Score:</strong> {{ $user->score }}</p>
        </div>
    </div>
</div>

    
@if (Auth::check() && ($isOwnProfile || (Auth::user()->admin && Auth::user()->id !== $user->id) && !Auth::user()->ban))
    <div class="mt-4 text-center">
        <a href="{{ route('profile.editAny', ['username' => $user->username]) }}" class="btn btn-primary">
            Edit Profile
        </a>
    </div>
@endif

@if (Auth::check() && Auth::user()->admin && $user->username !== 'anonymous' && !$isOwnProfile)
    <div class="mt-4 text-center">
        <form action="{{ route('profile.delete', $user->username) }}" method="POST" onsubmit="return confirm('Are you sure you want to delete this user? This action is irreversible.');" class="d-inline">
            @csrf
            @method('DELETE')
            <button type="submit" class="btn btn-danger">Delete User</button>
        </form>
    </div>
@endif

@if (Auth::check() && Auth::user()->admin && !$isOwnProfile && $user->username !== 'anonymous')
    <div class="mt-3 text-center">
        <form method="POST" action="{{ route('profile.toggleBan', $user->username) }}" class="d-inline">
            @csrf
            @method('PATCH')
            <button class="btn {{ $user->ban ? 'btn-danger' : 'btn-success' }}">
                {{ $user->ban ? 'Unban User' : 'Ban User' }}
            </button>
        </form>
    </div>
@endif



    

<div class="row mt-5 ms-5 me-5">
    <div class="col-md-6">
        <h4 class="mb-4 text-center">My Questions</h4>
        @forelse ($questions as $question)
            <div class="card shadow-sm mb-3">
                <div class="card-body">
                    <h5>
                        <a href="{{ route('questions.show', $question->id) }}" class="text-primary text-decoration-none">
                            {{ $question->title }}
                        </a>
                    </h5>
                    <p class="text-muted">{{ Str::limit($question->content, 100, '...') }}</p>
                    <div class="d-flex justify-content-between align-items-center">
                        <small><strong>Votes:</strong> {{ $question->votes }}</small>
                        <small><strong>Posted on:</strong> {{ $question->date }}</small>
                    </div>
                </div>
            </div>
        @empty
            <div class="alert alert-info text-center">
                <p>No questions found.</p>
            </div>
        @endforelse
    </div>

    <!-- My Answers Section -->
    <div class="col-md-6">
        <h4 class="mb-4 text-center">My Answers</h4>
        @forelse ($answers as $answer)
            <div class="card shadow-sm mb-3">
                <div class="card-body">
                    <p class="text-muted">{{ Str::limit($answer->content, 150, '...') }}</p>
                    <div class="mb-2">
                        <strong>Answered to:</strong> 
                        <a href="{{ route('questions.show', $answer->question->id) }}" class="text-primary text-decoration-none">
                            {{ $answer->question->title }}
                        </a>
                    </div>
                    <div class="d-flex justify-content-between align-items-center">
                        <small><strong>Votes:</strong> {{ $answer->votes }}</small>
                        <small><strong>Posted on:</strong> {{ $answer->date }}</small>
                    </div>
                </div>
            </div>
        @empty
            <div class="alert alert-info text-center">
                <p>No answers found.</p>
            </div>
        @endforelse
    </div>
</div>

@endsection

