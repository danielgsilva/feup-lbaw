@extends('layouts.app')

@section('content')
<div class="container vh-100 d-flex justify-content-center align-items-center">
    <div class="row w-100">
        <div class="col-md-6 mx-auto">
            <form method="POST" action="{{ route('login') }}" class="p-4 border rounded bg-light shadow-sm">
                {{ csrf_field() }}

                <div data-mdb-input-init class="form-outline mb-4">
                    <label for="email" class="form-label">E-mail</label>
                    <input id="email" class="form-control" type="email" name="email" value="{{ old('email') }}" required autofocus>
                    @if ($errors->has('email'))
                        <span class="text-danger small">
                            {{ $errors->first('email') }}
                        </span>
                    @endif
                </div>

                <div data-mdb-input-init class="form-outline mb-4">
                    <label for="password" class="form-label">Password</label>
                    <input id="password" class="form-control" type="password" name="password" required>
                    @if ($errors->has('password'))
                        <span class="text-danger small">
                            {{ $errors->first('password') }}
                        </span>
                    @endif
                    <div class="text-end">
                        <a href="{{ route('password.request') }}" class="text-decoration-none">Forgot Password?</a>
                    </div>
                </div>

                <div class="form-check mb-4">
                    <input class="form-check-input" type="checkbox" id="remember" name="remember" {{ old('remember') ? 'checked' : '' }}>
                    <label class="form-check-label" for="remember">Remember me</label>
                </div>

                <button type="submit" class="btn btn-primary btn-block w-100">
                    Login
                </button>

                <div class="text-center mt-3">
                    <p>Not a member? <a href="{{ route('register') }}" class="text-decoration-none">Register</a></p>
                </div>

                @if (session('success'))
                    <p class="text-success small mt-2">
                        {{ session('success') }}
                    </p>
                @endif
            </form>
        </div>
    </div>
</div>
@endsection
