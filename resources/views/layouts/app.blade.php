<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <!-- CSRF Token -->
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'Laravel') }}</title>

        <!-- Styles -->
        <link href="{{ url('css/milligram.min.css') }}" rel="stylesheet">
        <link href="{{ url('css/app.css') }}" rel="stylesheet">
        <script type="text/javascript">
            // Fix for Firefox autofocus CSS bug
            // See: http://stackoverflow.com/questions/18943276/html-5-autofocus-messes-up-css-loading/18945951#18945951
        </script>
        <script type="text/javascript" src={{ url('js/app.js') }} defer>
        </script>
    </head>
    <body>
    <main>
        <header>
            <div class="header-container d-flex justify-content-between align-items-center mt-3">
                <!-- Logo Section -->
                <h1><a href="{{ url('home') }}">AskIT</a></h1>

                <!-- Search Bar Section (centered) -->
                <div class="search-container d-flex justify-content-center align-items-center">
                    <form action="{{ route('questions.search') }}" method="GET" class="search-form d-flex">
                        <input type="text" name="query" placeholder="Search questions..." required class="form-control">
                        <button type="submit" class="btn btn-primary">Search</button>
                    </form>
                </div>

                <!-- User Authentication Dropdown -->
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
                <div class= "log">
                    <a href="{{ url('/login') }}"  class="button btn btn-primary">Login</a>
                </div>
                @endif
            </div>
        </header>
    




            <section id="content">
                @yield('content')
            </section>
            <footer>
                <p>&copy; 2024 AskIT</p>
                <a href="{{ url('/contacts') }}"> Contact us</a> <!-- Replace the url -->
                <a href="{{ url('/AskIT') }}"> About Us </a> <!-- Replace the url -->
            </footer>
        </main>
    </body>
</html>