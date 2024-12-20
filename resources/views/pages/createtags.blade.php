@extends('layouts.app')

@section('content')
<div class="container vh-100 d-flex justify-content-center align-items-center">
    <div class="row w-100">
        <div class="col-md-6 mx-auto">
            <form action="{{ route('tags.store') }}" method="POST" class="p-4 border rounded bg-light shadow-sm">
                @csrf

                <h1>Create New Tag</h1>

                <div class="form-group mb-4">
                    <label for="name" class="form-label">Tag Name</label>
                    <input type="text" id="name" name="name" class="form-control" required>
                    @if ($errors->has('name'))
                        <span class="text-danger small">
                            {{ $errors->first('name') }}
                        </span>
                    @endif
                </div>

                <button type="submit" class="btn btn-primary mt-3 w-100">Create Tag</button>
            </form>
        </div>
    </div>
</div>
@endsection
