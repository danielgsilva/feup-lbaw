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
        $tagIds = $request->query('tag_id', []); // Get tag IDs as an array if provided

        // Fetch all tags for the dropdown
        $tags = Tag::all();

        // Query questions, filtering by tags with AND logic
        $questions = Question::when(!empty($tagIds), function ($query) use ($tagIds) {
            foreach ($tagIds as $tagId) {
                $query->whereHas('tags', function ($subQuery) use ($tagId) {
                    $subQuery->where('tag.id', $tagId);
                });
            }
        })
        ->orderBy($order, 'desc')
        ->paginate(10);

        return view('pages.home', compact('questions', 'order', 'tags', 'tagIds'));
    }
}