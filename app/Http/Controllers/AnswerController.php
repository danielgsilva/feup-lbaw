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
}
