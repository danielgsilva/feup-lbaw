@extends('layouts.app')

@section('content')
<div class="container d-flex justify-content-center align-items-center" style="min-height: calc(100vh - 100px); margin-top: 50px; margin-bottom: 50px;">
    <div class="row w-100">
        <div class="col-md-6 mx-auto">
            <div class="p-5 border rounded bg-light shadow-sm">
                <h2 class="text-center mb-4">Password Recovery</h2>

                @if (session('status'))
                    <p class="alert alert-success text-center">
                        {{ session('status') }}
                    </p>
                @endif

                <form method="POST" action="{{ route('password.update') }}">
                    {{ csrf_field() }}

                    <input type="hidden" name="token" value="{{ $token }}">

                  
                    <div class="form-group mb-3">
                        <label for="email" class="form-label">E-Mail*</label>
                        <input id="email" type="email" name="email" value="{{ old('email') }}" class="form-control" placeholder="Email" required>
                        @if ($errors->has('email'))
                            <span class="text-danger small">
                                {{ $errors->first('email') }}
                            </span>
                        @endif
                    </div>

                  
                    <div class="form-group mb-3">
                        <label for="password" class="form-label">Password*</label>
                        <input id="password" type="password" name="password" class="form-control" placeholder="Password" required>
                        @if ($errors->has('password'))
                            <span class="text-danger small">
                                {{ $errors->first('password') }}
                            </span>
                        @endif
                    </div>

                 
                    <div class="form-group mb-3">
                        <label for="password_confirmation" class="form-label">Confirm Password*</label>
                        <input id="password_confirmation" type="password" name="password_confirmation" class="form-control" placeholder="Confirm Password" required>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 mt-3">
                        Save New Password
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
