<div class="question">
    <h2><a href="{{ route('home', $question->id) }}">{{ $question->title }}</a></h2>
    <p>{{ $question->body }}</p>
    <div class="question-meta">
        <span>Asked by: {{ $question->user->name }}</span>
    </div>
</div>