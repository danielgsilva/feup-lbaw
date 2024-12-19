@extends('layouts.app')

@section('content')
<div id="edit-profile">
    <h1>{{ isset($isAdminEditing) && $isAdminEditing ? 'Edit User Profile' : 'Edit Profile' }}</h1>

    @if (session('success'))
        <div class="alert alert-success">
            {{ session('success') }}
        </div>
    @endif

    @if ($errors->any())
        <div class="alert alert-danger">
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form method="POST" action="{{ isset($isAdminEditing) && $isAdminEditing ? route('profile.updateAny', $user->username) : route('profile.update') }}">
        @csrf
        @method('PATCH')

        <div class="form-group">
            <label for="name" class="form-label">Name</label>
            <input type="text" name="name" id="name" class="form-control" value="{{ old('name', $user->name) }}" required>
        </div>

        <div class="form-group">
            <label for="username" class="form-label">Username</label>
            <input type="text" name="username" id="username" class="form-control" value="{{ old('username', $user->username) }}" required>
        </div>

        <div class="form-group">
            <label for="bio" class="form-label">Bio</label>
            <textarea name="bio" id="bio" class="form-control" rows="3">{{ old('bio', $user->bio) }}</textarea>
        </div>

        @include('pages.tags')
        
        @include('partials.toast')

        <button type="submit" class="button">Save Changes</button>
    </form>
</div>

<script>const max_tags = 5</script>
<script>const tags = @json($tags);</script>
<script> const oldTagsList = @json($user->tags); </script>
@endsection
