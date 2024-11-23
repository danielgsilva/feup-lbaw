<<<<<<< HEAD
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Question;

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
=======
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
    public function show($id)
    {
        $question = Question::findOrFail($id);
        $answers = $question->answers()->paginate(5);
        $comments = $question->comments()->paginate(5);
        return view('pages.showQuestion', compact('question', 'answers', 'comments'));
    }

    

    public function create()
    {
        return view('pages.createquestion');
    }

    public function store(Request $request)
    {
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

        // Redirect to the home page or wherever you want
        return redirect()->route('home')->with('success', 'Question created successfully!');
    }


>>>>>>> 1f61eb056fc533a772ef5855c0d97f821d827f44
}