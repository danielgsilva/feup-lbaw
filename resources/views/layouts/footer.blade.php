<!DOCTYPE html>
<html lang="en">
<head>
    <!-- Your head content -->
</head>
<body class="d-flex flex-column min-vh-100">
    <div class="flex-grow-1">
        <!-- Your main content here -->
    </div>
    <footer class="pt-5 pb-3 mt-auto">
        <nav class="row container m-auto text-center">
            <div class="col-6 col-md">
                <h5>AskIT</h5>
                <ul class="list-unstyled text-small"></ul>
                    <li><a class="link-secondary" href="{{ route('home') }}">Home</a></li>
                    <li><a class="link-secondary" href="{{ url('home') }}">About us</a></li> 
                    <li><a class="link-secondary" href="{{ route('home') }}">Contact us</a></li> 
                </ul>
            </div>
            <div class="col-6 col-md">
                <h5>Authentication</h5>
                <ul class="list-unstyled text-small">
                    @if(!Auth::check())
                        <li><a class="link-secondary" href="{{ route('login') }}">Login</a></li>
                        <li><a class="link-secondary" href="{{ route('register') }}">Register</a></li>
                    @else 
                        <li><a class="link-secondary" href="{{ url('/profile/' . Auth::user()->username) }}">Profile</a></li>
                    @endif
                </ul>
            </div>
            <div class="col-6 col-md">
                <h5>Features</h5>
                <ul class="list-unstyled text-small">
                    <li><a class="link-secondary" href="{{ route('questions.search') }}">Search Questions</a></li>
                    <li><a class="link-secondary" href="{{ route('questions.create') }}">Add Question</a></li>
                </ul>
            </div>

            @if (Auth::check() && (Auth::user()->admin)) 
                <div class="col-6 col-md">
                    <h5>Management</h5>
                    <ul class="list-unstyled text-small">
                        <li><a class="link-secondary" href="{{route('home')}}">Manage Tags</a></li>
                        <li><a class="link-secondary" href="{{route('home')}}">Manage Reports</a></li>
                        <li><a class="link-secondary" href="{{route('home')}}">Manage Users</a></li>
                    </ul>
                </div>
            @endif
        </nav>
    </footer>
</body>
</html>