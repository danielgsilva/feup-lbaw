<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Question;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class QuestionController extends Controller
{
    public function index()
    {
        $questions = Question::all();
        return view('home', compact('questions'));
    }

    //For opening the question later
    public function show(Request $request, $id)
    {
        $question = Question::findOrFail($id);
        $order = $request->input('order', 'votes');
        $show = $request->input('show', 'answers');
        $answers = $question->answers()->orderBy($order, 'desc')->paginate(5);
        $comments = $question->comments()->orderBy('date', 'desc')->paginate(5);
        $userVote = DB::table('question_vote')
            ->where('id_user', Auth::id())
            ->where('id_question', $question->id)
            ->value('value') ?? 0;

        return view('pages.showQuestion', compact('question', 'answers', 'comments', 'order', 'show', 'userVote'));
    }


    public function create()
    {
        $this->authorize('create', Question::class);
        if(Auth::user()->ban){
            return redirect()->route('home')->with('error', 'You are banned and cannot create questions.');
        }
        return view('pages.createquestion');
    }

    public function store(Request $request)
    {
        $this->authorize('create', Question::class);

        if (Auth::user()->ban) {
            return redirect()->route('home')->withErrors(['message' => 'Account banned.']);
        }

        // Validate the form input
        $request->validate([
            'title' => 'required|string|max:1000',
            'content' => 'required|string',
        ]);

        

        // Create the question
        $question = new Question();
        $question->title = $request->title;
        $question->content = $request->content;
        $question->id_user = auth()->id(); // Assuming the user is logged in
        $question->save();

        // Redirect to the home page 
        return redirect()->route('home')->with('success', 'Question created successfully!');
    }

    public function edit($id)
    {
        $question = Question::findOrFail($id);
        $this->authorize('update', $question);
        return view('pages.editquestion', compact('question'));
    }

    public function update(Request $request, $id)
    {
        $question = Question::findOrFail($id);
        $this->authorize('update', $question);

        // Validate the form input
        $request->validate([
            'title' => 'required|string|max:1000',
            'content' => 'required|string',
        ]);

        // Update the question
        $question->title = $request->title;
        $question->content = $request->content;
        $question->edited = true;
        $question->save();
        

        // Redirect to the question page 
        return redirect()->route('questions.show', $question->id)->with('success', 'Question updated successfully!');
    }

        public function destroy($id)
        {
            $question = Question::findOrFail($id);
            $this->authorize('delete', $question);
            $question->delete();
            return redirect()->route('home')->with('success', 'Question deleted successfully!');
        }

    public function search(Request $request)
    {
        $search = $request->input('query');
        
        $questions = DB::table('question')
            ->select('question.id', 'question.title', 'question.content', 'question.date', 'users.username')
            ->join('users', 'users.id', '=', 'question.id_user')
            ->whereRaw("question.tsvectors @@ plainto_tsquery('english', ?)", [$search])
            ->orderByRaw("ts_rank(question.tsvectors, plainto_tsquery('english', ?)) DESC", [$search])
            ->paginate(10);

        return view('pages.search', compact('questions', 'search')); 
    }

    public function vote(Request $request, $id)
    {
        if (!Auth::check()) {
            return response()->json(['redirect' => route('login')], 401);
        }
        
        $request->validate([
            'vote' => 'required|in:1,-1,0', // 1 for upvote, -1 for downvote, 0 to remove vote
        ]);
    
        $question = Question::findOrFail($id);
        $user = Auth::user();
    
        // Check if the user has already voted on this question
        $existingVote = DB::table('question_vote')
            ->where('id_user', $user->id)
            ->where('id_question', $question->id)
            ->first();
    
        if ($existingVote) {
            if ($request->vote == 0) {
                // Remove vote if 0
                DB::table('question_vote')
                    ->where('id_user', $user->id)
                    ->where('id_question', $question->id)
                    ->delete();
            } else {
                // Update the vote
                DB::table('question_vote')
                    ->where('id_user', $user->id)
                    ->where('id_question', $question->id)
                    ->delete();
                
                DB::table('question_vote')->insert([
                    'id_user' => $user->id,
                    'id_question' => $question->id,
                    'value' => $request->vote,
                ]);
            }
        } else {
            if ($request->vote != 0) {
                // Create a new vote
                DB::table('question_vote')->insert([
                    'id_user' => $user->id,
                    'id_question' => $question->id,
                    'value' => $request->vote,
                ]);
            }
        }

        // Retrieve the updated vote count from the database
        $question->votes = DB::table('question')
            ->where('id', $question->id)
            ->value('votes');

        // Return JSON response with updated vote count and user's vote
        $userVote = DB::table('question_vote')
            ->where('id_user', $user->id)
            ->where('id_question', $question->id)
            ->value('value') ?? 0;

        return response()->json([
            'votes' => $question->votes,
            'userVote' => $userVote,
        ]);
    }
    
}