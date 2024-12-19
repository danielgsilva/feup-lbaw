<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Question extends Model
{
    use HasFactory;

    // Don't add create and update timestamps in database.
    public $timestamps  = false;

    protected $table = 'question';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'title',
        'content',
        'date',
        'reports',
        'votes',
        'edited',
        'id_user',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'id_user');
    }

    public function answers(): HasMany
    {
        return $this->hasMany(Answer::class, 'id_question');
    }

    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class, 'id_question');
    }

    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class, 'question_tag', 'id_question', 'id_tag');
    }

    public function followers(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'follow_question');
    }
}
