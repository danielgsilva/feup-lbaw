<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Comment;
use App\Models\Question;
use App\Models\Answer;
use Illuminate\Support\Facades\Auth;
use App\Events\SendNotification;

class CommentController extends Controller
{

    public function __construct() {
        $this->middleware('auth')->only('store');
    }
    public function store(Request $request)
    {
        $request->validate([
            'content' => 'required|string',
            'id_question' => 'nullable|integer|exists:question,id',
            'id_answer' => 'nullable|integer|exists:answer,id',
        ]);

        $comment = new Comment();
        $comment->content = $request->input('content');
        $comment->id_user = Auth::id();
        $comment->id_question = $request->input('id_question');
        $comment->id_answer = $request->input('id_answer');
        $comment->save();
        if($comment->id_answer == null){
            event(new SendNotification('There is a new comment to your question.', Question::find($comment->id_question)->id_user, $comment->id_question, null, false));
        } else {
            event(new SendNotification('There is a new comment to your answer.', Answer::find($comment->id_answer)->id_user, $comment->id_question, $comment->id_answer, false));
        }
        
        return redirect()->back()->with('success', 'Your comment has been posted.');
    }

    public function edit($id)
    {
        $comment = Comment::findOrFail($id);
        $this->authorize('edit', $comment);
        return view('comments.edit', compact('comment'));
    }


    public function update(Request $request, $id)
    {
        $comment = Comment::findOrFail($id);
        $this->authorize('update', $comment);

        $request->validate([
            'content' => 'required|string',
        ]);

        $comment->update([
            'content' => $request->input('content'),
        ]);

        return redirect()->back()->with('success', 'Your comment has been updated.');
    }

    public function show($id)
    {
        
        $comment = Comment::findOrFail($id);
    
    
        return view('pages.commentsshow', compact('comment'));
    }
    

}