@extends('layouts.app')

@section('content')
<div class="container py-5">
    <h1 class="text-center mb-4">About Us</h1>

    <div class="row">
        <div class="col-md-6">
            <h3>Our Story</h3>
            <p>We are a group of four students – Daniel, Diogo, Rafael, and Tiago – from the Faculty of Engineering at the University of Porto(FEUP). As part of our course on LBAW (Database and Web Applications Laboratory), we decided to develop a web application focused on collaborative Q&A. Through this project, we combined our passion for technology, web development, and collaboration, and we hope to make a positive impact on the way people learn and share information online.</p>
        </div>

        <div class="col-md-6">
            <h3>Our Mission</h3>
            <p>Create a space where developers can quickly find accurate, reliable answers to their coding questions. What sets it apart is the community-driven approach, where users contribute their expertise, and the platform's voting and reputation system rewards quality contributions. We hope to create a self-sustaining cycle of knowledge.</p>
        </div>
    </div>

    <div class="row mt-5">
        <div class="col-12 text-center mb-3">
            <h3 class="mb-4">Our Team</h3>
            <div class="row">
                <div class="col-md-3 mb-2">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">Daniel Silva</h5>
                            <p class="card-text">Student</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 mb-2">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">Diogo Ramos</h5>
                            <p class="card-text">Student</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 mb-2">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">Rafael Costa</h5>
                            <p class="card-text">Student</p>
                        </div>
                    </div>
                </div>

                <div class="col-md-3 mb-2">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">Tiago Pires</h5>
                            <p class="card-text">Student</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
