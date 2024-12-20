@extends('layouts.app')

@section('content')
<div class="container">
    <h2 class="my-4">Pesquisar Utilizadores</h2>

    <div class="mb-4">
        <input type="text" id="search-input" class="form-control" placeholder="Pesquise utilizadores..." />
    </div>

    <div id="loading-indicator" class="text-center d-none">
        <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">A carregar...</span>
        </div>
    </div>

    <ul id="user-list" class="list-group">
      
    </ul>
</div>

<script src="{{ asset('js/searchusers.js') }}"></script>

@endsection
