<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Question;
use Illuminate\Support\Facades\Auth;

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
        $answers = $question->answers()->orderBy($order,'desc')->paginate(5);
        $comments = $question->comments()->get();
        return view('pages.showQuestion', compact('question', 'answers', 'comments', 'order'));
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
}