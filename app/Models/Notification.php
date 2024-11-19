<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Notification extends Model
{
    use HasFactory;

    // Don't add create and update timestamps in database.
    public $timestamps  = false;

    protected $table = 'notification';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'date',
        'viewed',
        'id_user',
        'id_answer',
        'id_comment',
        'id_question_vote',
        'id_answer_vote',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'id_user');
    }

    public function answer(): BelongsTo
    {
        return $this->belongsTo(Answer::class, 'id_answer');
    }
    
    public function comment(): BelongsTo
    {
        return $this->belongsTo(Comment::class, 'id_comment');
    }
}
