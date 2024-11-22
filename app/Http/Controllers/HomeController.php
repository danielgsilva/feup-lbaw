<?php
namespace App\Http\Controllers;
use App\Models\Question;

class HomeController extends Controller
{
    
    public function index()
    {
        // Paginate the questions
        $questions = Question::paginate(10);
        return view('pages.home', compact('questions'));
    }
}