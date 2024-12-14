@extends('layouts.app')

@section('content')
<div id="register-section">
    <form method="POST" class="ms-5 me-5" action="{{ route('register') }}" enctype="multipart/form-data">
        {{ csrf_field() }}

        <img src="{{asset('storage/profile_images/default.png')}}" alt="profile image">
        <input id="profile_image" type="file" name="profile_image">
        <label for="profile_image">Profile Image</label>
        <!-- Images are not working -->

        <div data-mdb-input-init class="form-outline mb-4">
            <label for="username" class="form-label">Username</label>
            <input class="form-control" id="username" type="text" name="username" value="{{ old('username') }}" required autofocus>
            @if ($errors->has('username'))
                <span class="error --bs-danger">
                    {{ $errors->first('username') }}
                </span>
            @endif
        </div>

        <div data-mdb-input-init class="form-outline mb-4">
            <label for="name" class="form-label">Name</label>
            <input class="form-control" id="name" type="text" name="name" value="{{ old('name') }}" required>
            @if ($errors->has('name'))
                <span class="error --bs-danger">
                    {{ $errors->first('name') }}
                </span>
            @endif
        </div> 

        <div data-mdb-input-init class="form-outline mb-4">
            <label for="email" class="form-label">E-Mail Address</label>
            <input class="form-control" id="email" type="email" name="email" value="{{ old('email') }}" required>
            @if ($errors->has('email'))
                <span class="error --bs-danger">
                    {{ $errors->first('email') }}
                </span>
            @endif
        </div>

        <div data-mdb-input-init class="form-outline mb-4">
            <label class="form-label" for="password">Password</label>
            <input class="form-control" id="password" type="password" name="password" required>
            @if ($errors->has('password'))
                <span class="error --bs-danger">
                    {{ $errors->first('password') }}
                </span>
            @endif
        </div>

        <div data-mdb-input-init class="form-outline mb-4">
            <label class="form-label" for="password-confirm">Confirm Password</label>
            <input class="form-control" id="password-confirm" type="password" name="password_confirmation" required>
        </div>

        <button type="submit" data-mdb-button-init data-mdb-ripple-init class="btn btn-primary btn-block mb-4">
            Register
        </button>
        <a class="button-outline" href="{{ route('login') }}">Login</a>
    </form>
@endsection
