<header>
    <!-- navbar -->
    <nav class="navbar navbar-expand-xl navbar-dark bg-dark">
        <div class="container-fluid">

            <a class="navbar-brand" href="{{ url('home') }}">AskIT</a>

            <!-- toggle button for mobile nav -->
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarSupportedContent">

                <form class="d-flex me-auto" role="search" action="{{ route('questions.search') }}" method="GET">
                    <input class="form-control" type="search" placeholder="Search questions..." aria-label="Search" name="query" required>
                    <button class="btn btn-primary" type="submit">Search</button>
                </form>

                @if (Auth::check())
                <div class="dropdown">
                    <button class="dropbtn">{{ Auth::user()->name }}</button>
                    <div class="dropdown-content">
                        <a href="{{ url('/profile/' . Auth::user()->username) }}">Profile</a>
                        <a href="{{ url('/notifications') }}">Notifications</a>
                        @if (Auth::user()->admin)
                        <form action="{{ route('profile.search') }}" method="GET" style="margin: 10px;">
                            <input type="text" name="query" placeholder="Search Profiles" required>
                            <button type="submit">Search</button>
                        </form>
                        @endif
                        <a href="{{ url('/logout') }}">Logout</a>
                    </div>
                </div>
                @else
                <div class="log">
                    <a href="{{ url('/login') }}" class="button btn btn-primary">Login</a>
                </div>
                @endif

            </div>
        </div>
    </nav>
</header>