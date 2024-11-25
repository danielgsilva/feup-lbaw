@extends('layouts.app')

@section('content')

    @if ($errors->any())
        <div class="alert alert-danger">
            @foreach ($errors->all() as $error)
                <p>{{ $error }}</p>
            @endforeach
        </div>
    @endif

    @isset($users)
    <div class = "search-users">
        <h2>User Search Results:</h2>
        @if($users->isNotEmpty())
    <div class="user-list">
        @foreach($users as $user)
            <div class="user-item">
                <a href="{{ route('profile.show', ['username' => $user->username]) }}">
                    {{ $user->name }} ({{ $user->username }})
                </a>
            </div>
        @endforeach
    </div>
</div>
@else
    <p class="no-results">No users found matching your query.</p>
@endif
    @endisset
@endsection
