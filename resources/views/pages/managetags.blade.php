@extends('layouts.app')

@section('content')
<div class="container mt-3 mb-3">
    <h1>Manage Tags</h1>

    @if(session('success'))
        <div class="alert alert-success" id="success-message">
            {{ session('success') }}
        </div>
        <script>
            
            setTimeout(function() {
                document.getElementById('success-message').style.display = 'none';
            }, 3000); 
        </script>
    @endif

    <a href="{{ route('tags.create') }}" class="btn btn-primary mt-2 mb-3">Create New Tag</a>

    <table class="table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            @foreach($tags as $tag)
                <tr>
                    <td>{{ $tag->name }}</td>
                    <td>
                        <a href="{{ route('tags.edit', $tag->id) }}" class="btn btn-warning btn-sm">Edit</a>
                        <form action="{{ route('tags.destroy', $tag->id) }}" method="POST" style="display:inline;">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                        </form>
                    </td>
                </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection
