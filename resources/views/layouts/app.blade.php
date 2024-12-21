<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
    <head>
        @include('layouts.head')
    </head>
    <body>
        <main>
            @include('layouts.header')
            <section id="content">
                @yield('content')
            </section>
        </main>
        @include('layouts.footer')
    </body>
    <script>
        window.PUSHER_APP_KEY = "{{ env('PUSHER_APP_KEY') }}";
        window.PUSHER_APP_CLUSTER = "{{ env('PUSHER_APP_CLUSTER') }}";
    </script>

    <script>
        @if(auth()->check())
            window.userId = {{ auth()->user()->id }};
        @else
            window.userId = null;
        @endif
    </script>

</html>
