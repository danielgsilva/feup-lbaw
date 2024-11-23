<?php
namespace App\Http\Controllers;
use App\Models\Question;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    
    public function index(Request $request)
    {
        $order = $request->query('order', 'votes'); // Default order by votes
        $questions = Question::orderBy($order, 'desc')->paginate(10);
        return view('pages.home', compact('questions', 'order'));
    }
}