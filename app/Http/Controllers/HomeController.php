<?php
namespace App\Http\Controllers;
use App\Models\Question;

class HomeController extends Controller
{
    /**
     * Show the homepage.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        // Paginate the questions
        $questions = Question::paginate(10); // Adjust the number as needed
        return view('pages.home', compact('questions'));
    }
}