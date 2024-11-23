<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Answer;
use App\Models\Question;
use Illuminate\Support\Facades\Auth;

class AnswerController extends Controller
{
    // Show form to create a new answer for a specific question
    public function create($id)
    {
        $question = Question::findOrFail($id);
        return view('answers.create', compact('question'));
    }

    // Store the new answer
    public function store(Request $request)
    {
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
}
