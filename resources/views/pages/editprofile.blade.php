@extends('layouts.app')

@section('content')
<div class="container d-flex justify-content-center align-items-center" style="min-height: calc(100vh - 100px); margin-top: 50px; margin-bottom: 50px;">
    <div class="row w-100">
        <div class="col-md-6 mx-auto">
            <div class="p-4 border rounded bg-light shadow-sm">
                <h1 class="text-center mb-4">
                    {{ isset($isAdminEditing) && $isAdminEditing ? 'Edit User Profile' : 'Edit Profile' }}
                </h1>

                @if (session('success'))
                    <div class="alert alert-success">
                        {{ session('success') }}
                    </div>
                @endif

                @if ($errors->any())
                    <div class="alert alert-danger">
                        <ul class="mb-0">
                            @foreach ($errors->all() as $error)
                                <li>{{ $error }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endif

                <form method="POST" action="{{ isset($isAdminEditing) && $isAdminEditing ? route('profile.updateAny', $user->username) : route('profile.update') }}" enctype="multipart/form-data">
                    @csrf
                    @method('PATCH')

                    <div class="text-center mb-4">
                       
                       
                        <div>
                            <label for="profile_image" class="form-label">Imagem de Perfil</label>
                            <input id="profile_image" type="file" name="profile_image" class="form-control">
                        </div>
                    </div>

                    <div class="form-group mb-3">
                        <label for="name" class="form-label">Name</label>
                        <input type="text" name="name" id="name" class="form-control" value="{{ old('name', $user->name) }}" required>
                    </div>

                    <div class="form-group mb-3">
                        <label for="username" class="form-label">Username</label>
                        <input type="text" name="username" id="username" class="form-control" value="{{ old('username', $user->username) }}" required>
                    </div>

                    <div class="form-group mb-4">
                        <label for="bio" class="form-label">Bio</label>
                        <textarea name="bio" id="bio" class="form-control" rows="3">{{ old('bio', $user->bio) }}</textarea>
                    </div>

                    <button type="submit" class="btn btn-primary w-100">Save Changes</button>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
