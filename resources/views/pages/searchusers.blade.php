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
        <h2>Results</h2>
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
@endif
    @endisset
@endsection
