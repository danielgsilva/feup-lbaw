<?php
namespace App\Http\Controllers;
use App\Models\Question;
use App\Models\Tag;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    
    public function index(Request $request)
    {
        $order = $request->query('order', 'votes');
        $tagIds = $request->query('tag_id', []); 

        
        $tags = Tag::all();

        
        $questions = Question::when(!empty($tagIds), function ($query) use ($tagIds) {
            foreach ($tagIds as $tagId) {
                $query->whereHas('tags', function ($subQuery) use ($tagIds) {
                    $subQuery->whereIn('tag.id', $tagIds);
                });
            }
        })
        ->orderBy($order, 'desc')
        ->paginate(10);

        return view('pages.home', compact('questions', 'order', 'tags', 'tagIds'));
    }
}