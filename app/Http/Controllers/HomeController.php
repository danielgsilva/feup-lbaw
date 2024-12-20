<?php
namespace App\Http\Controllers;
use App\Models\Question;
use App\Models\Tag;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    
    public function index(Request $request)
    {
        $order = $request->query('order', 'votes'); // Default order by votes
        $tagId = $request->query('tag_id'); // Get the tag ID if provided

        // Fetch all tags for the dropdown
        $tags = Tag::all();

        // Query questions, and filter by tag if a tag ID is provided
        $questions = Question::when($tagId, function ($query) use ($tagId) {
            return $query->whereHas('tags', function ($query) use ($tagId) {
                $query->where('tag.id', $tagId);
            });
        })
        ->orderBy($order, 'desc')
        ->paginate(10);

        return view('pages.home', compact('questions', 'order', 'tags', 'tagId'));
    }
}