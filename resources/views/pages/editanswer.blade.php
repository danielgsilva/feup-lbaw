@extends('layouts.app')

@section('content')
<div class="container vh-100 d-flex justify-content-center align-items-center">
    <div class="row w-100">
        <div class="col-md-6 mx-auto">
            <form action="{{ route('answers.update', $answer->id) }}" method="POST" class="p-4 border rounded bg-light shadow-sm">
                @csrf
                @method('PUT')

                <h1 class="text-center mb-4">Edit Answer</h1>

                <div class="form-outline mb-4">
                    <label for="content" class="form-label">Answer</label>
                    <textarea name="content" class="form-control" rows="5">{{ $answer->content }}</textarea>
                    @if ($errors->has('content'))
                        <span class="text-danger small">
                            {{ $errors->first('content') }}
                        </span>
                    @endif
                </div>

                <button type="submit" class="btn btn-primary btn-block w-100 mb-3">
                    Change Answer
                </button>
            </form>
        </div>
    </div>
</div>
@endsection
