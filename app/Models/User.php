<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

// Added to define Eloquent relationships.
use Illuminate\Database\Eloquent\Relations\HasMany;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    // Don't add create and update timestamps in database.
    public $timestamps  = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'admin',
        'username',
        'name',
        'email',
        'bio',
        'birthdate',
        'password',
        'signUpDate',
        'ban',
        'score',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    /**
     * Get the questions for a user.
     */
    public function questions(): HasMany
    {
        return $this->hasMany(Question::class, 'id_user');
    }

    /**
     * Get the answers for a user.
     */
    public function answers(): HasMany
    {
        return $this->hasMany(Answer::class, 'id_user');
    }

    /**
     * Get the comments for a user.
     */
    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class, 'id_user');
    }

    public function tags() : BelongsToMany
    {
        return $this->belongsToMany(Tag::class, 'follow_tag', 'id_user', 'id_tag');
    }
}
