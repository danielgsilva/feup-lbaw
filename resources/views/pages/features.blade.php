@extends('layouts.app')

@section('content')
<div class="container py-5">
    <h1 class="text-center mb-5">Main Features</h1>

    <div class="row">
        <div class="col-md-6 mb-4">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Search Questions & Tags</h5>
                    <p class="card-text">Easily search for questions and tags to find relevant discussions and solutions quickly, improving your learning experience and saving time.</p>
                </div>
            </div>
        </div>

    
        <div class="col-md-6 mb-4">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">View Answers & Comments</h5>
                    <p class="card-text">View detailed answers and insightful comments from the community to better understand solutions and gain new perspectives.</p>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-6 mb-4">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Log in with GitHub and Google</h5>
                    <p class="card-text">Log in using your GitHub or Google account, making it easy to participate without the problem of creating a new account.</p>
                </div>
            </div>
        </div>

       
        <div class="col-md-6 mb-4">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Report Content</h5>
                    <p class="card-text">Report inappropriate or irrelevant content to help maintain a high-quality and respectful community environment.</p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
