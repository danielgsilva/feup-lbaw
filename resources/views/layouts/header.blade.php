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

                <form class="d-flex me-auto mt-2" role="search" action="{{ route('questions.search') }}" method="GET">
                    <input class="form-control " type="search" placeholder="Search questions..." aria-label="Search" name="query" required>
                    <button class="btn btn-primary ms-2" type="submit">Search</button>
                </form>

                @if (Auth::check())
                <div class="dropdown mt-1">
                    <button class="btn btn-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">{{ Auth::user()->name }}</button>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a href="{{ url('/profile/' . Auth::user()->username) }}" class="dropdown-item">Profile</a></li>
                        <li><a href="{{ url(path: '/notifications') }}" class="dropdown-item">Notifications</a></li>
                        <!--
                        @if (Auth::user()->admin)
                        <li>
                            <form action="{{ route('profile.search') }}" method="GET" style="margin: 10px;">
                                <input type="text" name="query" placeholder="Search Profiles" required>
                                <button type="submit">Search</button>
                            </form>
                        </li>
                        @endif

                        This should become a button to lead you to a user search page.
                        -->
                        <li><a href="{{ url('/logout') }}" class="dropdown-item">Logout</a></li>
                    </ul>
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