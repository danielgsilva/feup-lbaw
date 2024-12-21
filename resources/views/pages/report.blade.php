@extends('layouts.app')

@section('content')
<div class="container vh-100 d-flex justify-content-center align-items-center">
    <div class="row w-100">
        <div class="col-md-8 mx-auto">
            <form method="POST" action="{{ route('report.store') }}" class="p-4 border rounded bg-light shadow-sm">
                @csrf

                <h1 class="mb-4">Report {{ ucfirst($type) }}</h1>

                @if(session('success'))
                    <div class="alert alert-success">
                        {{ session('success') }}
                    </div>
                @endif

                @if(session('error'))
                    <div class="alert alert-danger">
                        {{ session('error') }}
                    </div>
                @endif

                <input type="hidden" name="id_entity" value="{{ $entity->id }}">
                <input type="hidden" name="entity_type" value="{{ $type }}">

                <div class="form-group mb-4">
                    <label for="content">Report reason:</label>
                    <textarea name="content" id="content" class="form-control w-100" rows="6" placeholder="Describe the reason for your report" required></textarea>
                </div>

                <button type="submit" class="btn btn-danger w-100 mb-3">Send Report</button>
            </form>
        </div>
    </div>
</div>
@endsection
