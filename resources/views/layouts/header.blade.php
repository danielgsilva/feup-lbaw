<header>
   
    <nav class="navbar navbar-expand-xl navbar-dark bg-dark">
        <div class="container-fluid">

            
            <a class="navbar-brand" href="{{ url('home') }}">AskIT</a>

            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarSupportedContent">

                
                <form class="d-flex me-auto mt-2" role="search" action="{{ route('questions.search') }}" method="GET">
                    <input class="form-control" type="search" placeholder="Search questions..." aria-label="Search" name="query" required>
                    <button class="btn btn-primary ms-2" type="submit">Search</button>
                </form>

                @if (Auth::check())
                   
                    @if (Auth::user()->admin)
                    <div class="dropdown mt-1 me-4">
                        <button class="btn btn-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            Admin Panel
                        </button>
                        <ul class="dropdown-menu dropdown-menu-start dropdown-menu-md-start dropdown-menu-lg-end">
                            <li><a href="{{ route('reports.index') }}" class="dropdown-item">Reports</a></li>
                            <li><a href="{{ route('profile.searchPage') }}" class="dropdown-item">Search Users</a></li>
                            <li><a href="{{ route('tags.index') }}" class="dropdown-item">Manage Tags   </a></li>
                        </ul>
                    </div>
                    @endif

                    
                    <div class="dropdown mt-1">
                        <button class="btn btn-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            {{ Auth::user()->name }}
                        </button>
                        <ul class="dropdown-menu dropdown-menu-start dropdown-menu-md-start dropdown-menu-lg-end">
                            <li><a href="{{ url('/profile/' . Auth::user()->username) }}" class="dropdown-item">Profile</a></li>
                            <li>
                                <a href="{{ route('notifications.index') }}" class="dropdown-item">
                                    Notifications
                                    @if(isset($unreadNotifications) && $unreadNotifications->count() > 0)
                                        <span class="badge bg-danger ms-2">{{ $unreadNotifications->count() }}</span>
                                    @endif
                                </a>
                            </li>
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
