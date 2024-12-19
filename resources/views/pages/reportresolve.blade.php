@extends('layouts.app')

@section('content')
<div class="container">
    <h1>Reports</h1>

    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @elseif(session('error'))
        <div class="alert alert-danger">{{ session('error') }}</div>
    @endif

    <table class="table">
        <thead>
            <tr>
                <th>Report ID</th>
                <th>Content</th>
                <th>Date</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            @foreach($reports as $report)
                <tr>
                    <td>{{ $report->id }}</td>
                    <td>
                        @if($report->question)
                            <a href="{{ route('questions.show', $report->question->id) }}">
                                {{ $report->content }}
                            </a>
                        @elseif($report->answer)
                            <a href="{{ route('answers.comments', $report->answer->id) }}">
                                {{ $report->content }}
                            </a>
                        @else
                            {{ $report->content }}
                        @endif
                    </td>
                    <td>{{ $report->created_at }}</td>
                    <td>
                        <form action="{{ route('reports.resolve', $report->id) }}" method="POST">
                            @csrf
                            @method('PUT')
                            <button type="submit" class="btn btn-success btn-sm">Report solved</button>
                        </form>
                    </td>
                </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection
