<?php

namespace App\Http\Controllers;

use App\Models\Tag;
use Illuminate\Http\Request;

class TagController extends Controller
{
    
    public function index()
    {
        $tags = Tag::all();
        return view('pages.managetags', compact('tags'));
    }

    public function create()
    {
        return view('pages.createtags');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255|unique:tag,name',
        ]);

        Tag::create([
            'name' => $request->name,
        ]);

        return redirect()->route('tags.index')->with('success', 'Tag created!');
    }

   
    public function edit(Tag $tag)
    {
        return view('pages.edittags', compact('tag'));
    }

  
    public function update(Request $request, Tag $tag)
    {
        $request->validate([
            'name' => 'required|string|max:255|unique:tag,name,' . $tag->id,
        ]);

        $tag->update([
            'name' => $request->name,
        ]);

        return redirect()->route('tags.index')->with('success', 'Tag updated!');
    }

    public function destroy(Tag $tag)
    {
        $tag->delete();

        return redirect()->route('tags.index')->with('success', 'Tag deleted!');
    }

    public function show($id)
    {
        
        $tag = Tag::findOrFail($id);
    
    
        return view('pages.tagshow', compact('tags'));
    }
}
