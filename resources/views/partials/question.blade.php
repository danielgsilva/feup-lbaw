<div class="question">
    <h2><a href="{{ route('questions.show', $question->id) }}">{{ $question->title }}</a></h2>
    <p>{{ $question->content }}</p>
    <div class="question-meta">
        <span>Asked by: 
            @if ($question->user)
            <a href="{{ route('profile.show', $question->user->username) }}">{{ $question->user->name }}</a> on {{ $question->date }}
            @else
            Anonymous on {{ $question->date }}
            @endif
        </span>
        <span>Votes: {{ $question->votes }}</span>
    </div>
</div>

<!--
Question model:
    protected $fillable = [
            'title',
            'content',
            'date',
            'reports',
            'votes',
            'edited',
            'id_user',
    ];
-->