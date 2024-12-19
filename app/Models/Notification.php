<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\DB;


class Notification extends Model
{
    use HasFactory;

    // If you dont want to add create and update timestamps in database set this to false
    public $timestamps  = false;

    protected $table = 'notification';

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
    public function getQuestionFromVote()
    {
        return DB::table('question_vote')
            ->join('question', 'question_vote.id_question', '=', 'question.id')
            ->where('question_vote.id', $this->id_question_vote)
            ->select('question.*')
            ->first();
    }

    public function getAnswerFromVote()
    {
    return DB::table('answer_vote')
        ->join('answer', 'answer_vote.id_answer', '=', 'answer.id')
        ->join('question', 'answer.id_question', '=', 'question.id')
        ->where('answer_vote.id', $this->id_answer_vote)
        ->select('answer.*', 'question.title as question_title', 'question.id as question_id')
        ->first();
    }
}
