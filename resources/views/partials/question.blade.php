<div class="card mb-4">
    <div class="card-body">
        <h2><a href="{{ route('questions.show', $question->id) }}" class="text-decoration-none text-dark">{{ $question->title }}</a>
        @if ($question->edited)
            <span class="badge bg-light text-muted ms-2"><i>(Edited)</i></span>
        @endif
        </h2>
        
        <p>{{ $question->content }}</p>

        <div class="d-flex justify-content-between align-items-center">
            <span class="text-muted">
                Asked by: 
                @if ($question->user)
                    <a href="{{ route('profile.show', $question->user->username) }}">{{ $question->user->name }}</a> on {{ $question->date }}
                @else
                    Anonymous on {{ $question->date }}
                @endif
            </span>

            <span class="badge badge-info">
                Votes: {{ $question->votes }}
            </span>
            <span class="badge badge-secondary">
                Answers: {{ $question->answers->count() }}
            </span>
        </div>
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