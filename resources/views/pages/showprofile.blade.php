<!-- resources/views/profile/show.blade.php -->

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
            <p><strong>Bio:</strong> {{ $user->bio ?? 'No bio available' }}</p>
            <p><strong>Score:</strong> {{ $user->score }}</p>
        </div>
    </div>

    <div class="mt-3">
        <a href="{{ route('profile.edit') }}" class="btn btn-primary">Edit Profile</a>
    </div>
    
</div>
@endsection
