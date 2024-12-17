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

                <form method="POST" action="{{ route('password.email') }}">
                    {{ csrf_field() }}

                    <div class="form-group mb-3">
                        <label for="email" class="form-label">E-mail</label>
                        <input id="email" type="email" name="email" value="{{ old('email') }}" class="form-control" placeholder="Email" required autofocus>
                        @if ($errors->has('email'))
                            <span class="text-danger small">
                                {{ $errors->first('email') }}
                            </span>
                        @endif
                    </div>

                    <button type="submit" class="btn btn-primary w-100">
                        Send Email
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
