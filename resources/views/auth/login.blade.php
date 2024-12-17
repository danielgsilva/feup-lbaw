@extends('layouts.app')

@section('content')
    <form method="POST" class="ms-5 me-5" action="{{ route('login') }}">
        {{ csrf_field() }}

        <div data-mdb-input-init class="form-outline mb-4">
        <label for="email" class="form-label">E-mail</label>
        <input id="email" class="form-control" type="email" name="email" value="{{ old('email') }}" required autofocus>
        @if ($errors->has('email'))
            <span class="error --bs-danger">
                {{ $errors->first('email') }}
            </span>
        @endif
        </div>
        
        <div data-mdb-input-init class="form-outline mb-4">
            <label for="password" class="form-label"> Password</label>
            <input id="password" class="form-control" type="password" name="password" required>
            @if ($errors->has('password'))
                <span class="error --bs-danger">
                    {{ $errors->first('password') }}
                </span>
            @endif
            <div class="text-end">
                <a href="{{ route('password.request') }}">Forgot Password</a>
            </div>
        </div>
        
        <div class="row mb-4">
            <div class="col d-flex justify-content-center">
              <!-- Checkbox -->
              <div class="form-check">
                <input class="form-check-input" type="checkbox" id="remember" name="remember" {{ old('remember') ? 'checked' : '' }}/>
                <label class="form-check-label" for="remember"> Remember me </label>
              </div>
            </div>

        <button type="submit" data-mdb-button-init data-mdb-ripple-init class="btn btn-primary btn-block mb-4">
            Login
        </button>

        <div class="text-center">
            <p>Not a member? <a href="{{ route('register') }}">Register</a></p>
        </div>
        
        @if (session('success'))
            <p class="success --bs-success">
                {{ session('success') }}
            </p>
        @endif
    </form>
@endsection
