<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Comment extends Model
{
    use HasFactory;

    // Don't add create and update timestamps in database.
    public $timestamps  = false;

    protected $table = 'comment';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'content',
        'date',
        'reports',
        'edited',
        'id_user',
        'id_question',
        'id_answer',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'id_user');
    }

    public function question(): BelongsTo
    {
        return $this->belongsTo(Question::class, 'id_question');
    }

    public function answer(): BelongsTo
    {
        return $this->belongsTo(Answer::class, 'id_answer');
    }

    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class, 'id_comment');
    }
}
