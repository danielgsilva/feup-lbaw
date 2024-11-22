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
    public function show($id)
    {
        $question = Question::findOrFail($id);
        $answers = $question->answers()->paginate(5);
        $comments = $question->comments()->paginate(5);
        return view('pages.showQuestion', compact('question', 'answers', 'comments'));
    }

}