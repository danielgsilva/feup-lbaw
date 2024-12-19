<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Answer;
use App\Models\Question;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class AnswerController extends Controller
{
    // Show form to create a new answer for a specific question
    public function create($id)
    {
        $question = Question::findOrFail($id);
        $this->authorize('create', [Answer::class, $question]);
        if (Auth::user()->ban) {
            return redirect()->route('home')->withErrors(['message' => 'A sua conta está suspensa.']);
        }
        return view('answers.create', compact('question'));
    }

    // Store the new answer
    public function store(Request $request)
    {
        $question = Question::findOrFail($request->input('id_question'));
        if (Auth::id() === $question->id_user) {
            return redirect()->route('questions.show', $question->id)
                     ->withErrors(['message' => 'You cannot answer to your own question.']);
        }

        try {
            $this->authorize('create', [Answer::class, $question]);
        } catch (\Illuminate\Auth\Access\AuthorizationException $e) {
            return redirect()->route('questions.show', $question->id)
                     ->withErrors(['message' => 'You are not authorized to create an answer for this question.']);
        }
    
        if (Auth::user()->ban) {
            return redirect()->route('home')->withErrors(['message' => 'A sua conta está suspensa.']);
        }

        $request->validate([
            'content' => 'required|string',
            'id_question' => 'required|integer|exists:question,id',
        ]);

        // Create a new answer
        Answer::create([
            'content' => $request->input('content'),
            'id_user' => Auth::id(),
            'id_question' => $request->input('id_question'),
        ]);

        // Redirect back to the question page
        return redirect()->route('questions.show', $request->input('id_question'))
                         ->with('success', 'Your answer has been posted.');
    }

        
    public function edit($id)
    {
        $answer = Answer::findOrFail($id);
        $this->authorize('edit', $answer);
        $question = Question::findOrFail($answer->id_question);
        return view('pages.editanswer', compact('answer', 'question'));
    }

    public function update(Request $request, $id)
    {
        $answer = Answer::findOrFail($id);
        $this->authorize('update', $answer);

        $request->validate([
            'content' => 'required|string',
        ]);

        $answer->update([
            'content' => $request->input('content'),
        ]);

        return redirect()->route('questions.show', $answer->id_question)->with('success', 'Your answer has been updated.');
    }

    public function destroy($id)
    {
        $answer = Answer::findOrFail($id);
        $this->authorize('delete', $answer);
        if (Auth::id() !== $answer->id_user) {
            return redirect()->route('questions.show', $answer->id_question)->with('error', 'Unauthorized action.');
        }

        $answer->delete();

        return redirect()->route('questions.show', $answer->id_question)->with('success', 'Your answer has been deleted.');
    }

    public function showComments($id) {

        $answer = Answer::with('comments.user')->findOrFail($id);
        $question = $answer->question;
        $comments = $answer->comments()->paginate(5);  

        return view('pages.showComments', compact('answer', 'question', 'comments'));
    }

    public function vote(Request $request, $id)
    {
        if (!Auth::check()) {
            return response()->json(['redirect' => route('login')], 401);
        }

        
        $request->validate([
            'vote' => 'required|in:1,-1,0', // 1 for upvote, -1 for downvote, 0 to remove vote
        ]);
    
        $answer = Answer::findOrFail($id);
        $user = Auth::user();
    
        // Check if the user has already voted on this answer
        $existingVote = DB::table('answer_vote')
            ->where('id_user', $user->id)
            ->where('id_answer', $answer->id)
            ->first();
    
        if ($existingVote) {
            if ($request->vote == 0) {
                // Remove the vote if 0
                DB::table('answer_vote')
                    ->where('id_user', $user->id)
                    ->where('id_answer', $answer->id)
                    ->delete();
            } else {
                // Update the vote
                DB::table('answer_vote')
                    ->where('id_user', $user->id)
                    ->where('id_answer', $answer->id)
                    ->delete();
                
                DB::table('answer_vote')->insert([
                    'id_user' => $user->id,
                    'id_answer' => $answer->id,
                    'value' => $request->vote,
                ]);
            }
        } else {
            if ($request->vote != 0) {
                // Create a new vote
                DB::table('answer_vote')->insert([
                    'id_user' => $user->id,
                    'id_answer' => $answer->id,
                    'value' => $request->vote,
                ]);
            }
        }
    
        // Retrieve the updated vote count from the database
        $answer->votes = DB::table('answer')
            ->where('id', $answer->id)
            ->value('votes');
    
        // Retrieve the user's current vote
        $userVote = DB::table('answer_vote')
            ->where('id_user', $user->id)
            ->where('id_answer', $answer->id)
            ->value('value') ?? 0;
    
        // Return a JSON response with updated vote count and user's vote
        return response()->json([
            'votes' => $answer->votes,
            'userVote' => $userVote,
        ]);
    }
    
}
