@extends('layouts.app')

@section('content')
<div class="container d-flex justify-content-center align-items-center" style="min-height: 100vh;">
    <div class="row w-100">
        <div class="col-md-6 mx-auto">
            <div class="p-4 border rounded bg-light shadow-sm" style="max-height: 90vh; overflow-y: auto;">
                <form method="POST" action="{{ route('register') }}" enctype="multipart/form-data">
                    {{ csrf_field() }}

                    <div class="text-center mb-4">
                        <img src="{{ asset('storage/profile_images/default.png') }}" alt="profile image" class="img-thumbnail rounded-circle mb-3" width="120" height="120">
                        <div>
                            <label for="profile_image" class="form-label">Imagem de Perfil</label>
                            <input id="profile_image" type="file" name="profile_image" class="form-control">
                        </div>
                    </div>

                    <div class="form-outline mb-4">
                        <label for="username" class="form-label">Username</label>
                        <input id="username" class="form-control" type="text" name="username" value="{{ old('username') }}" required autofocus>
                        @if ($errors->has('username'))
                            <span class="text-danger small">{{ $errors->first('username') }}</span>
                        @endif
                    </div>

                    <div class="form-outline mb-4">
                        <label for="name" class="form-label">Name</label>
                        <input id="name" class="form-control" type="text" name="name" value="{{ old('name') }}" required>
                        @if ($errors->has('name'))
                            <span class="text-danger small">{{ $errors->first('name') }}</span>
                        @endif
                    </div>

                    <div class="form-outline mb-4">
                        <label for="email" class="form-label">E-mail</label>
                        <input id="email" class="form-control" type="email" name="email" value="{{ old('email') }}" required>
                        @if ($errors->has('email'))
                            <span class="text-danger small">{{ $errors->first('email') }}</span>
                        @endif
                    </div>

                    <div class="form-outline mb-4">
                        <label for="password" class="form-label">Password</label>
                        <input id="password" class="form-control" type="password" name="password" required>
                        @if ($errors->has('password'))
                            <span class="text-danger small">{{ $errors->first('password') }}</span>
                        @endif
                    </div>

                    <div class="form-outline mb-4">
                        <label for="password-confirm" class="form-label">Confirmar Password</label>
                        <input id="password-confirm" class="form-control" type="password" name="password_confirmation" required>
                    </div>

                    <button type="submit" class="btn btn-primary btn-block w-100">Registar</button>

                    <div class="text-center mt-3">
                        <p>Já tem conta? <a href="{{ route('login') }}" class="text-decoration-none">Login</a></p>
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
</div>
@endsection
