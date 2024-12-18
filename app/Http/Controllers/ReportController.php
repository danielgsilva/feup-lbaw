<?php
namespace App\Http\Controllers;

use App\Models\Report;
use App\Models\Question;
use App\Models\Answer;
use App\Models\Comment;
use Illuminate\Http\Request;

class ReportController extends Controller
{
     public function index()
    {
        
        if (auth()->user()->admin) {
            $reports = Report::all();  
            return view('pages.reportresolve', compact('reports'));
        }

        return redirect()->route('home')->with('error', 'You do not have permissions.');
    }

    public function resolve(Report $report)
    {
        
        if (auth()->user()->admin) {
            
            $report->delete();

            return redirect()->route('reports.index')->with('success', 'The report was solved with success.');
        }

        return redirect()->route('home')->with('error', 'You do not have permissions to do that.');
    }
    
    public function create($type, $id)
    {
     
        $entity = null;
        switch ($type) {
            case 'question':
                $entity = Question::findOrFail($id);
                break;
            case 'answer':
                $entity = Answer::findOrFail($id);
                break;
            case 'comment':
                $entity = Comment::findOrFail($id);
                break;
        }

      
        return view('pages.report', compact('entity', 'type'));
    }

    public function store(Request $request)
    {
        
        $validated = $request->validate([
            'content' => 'required|string',
            'id_entity' => 'required|integer',
            'entity_type' => 'required|string',
        ]);

        $existingReport = Report::where('id_user', auth()->id())
        ->where('id_' . $validated['entity_type'], $validated['id_entity'])
        ->exists();

        if ($existingReport) {
        return redirect()->route('report.create', ['type' => $validated['entity_type'], 'id' => $validated['id_entity']])
            ->with('error', 'You already reported this post.');
        }

       
        $report = new Report();
        $report->content = $validated['content'];
        $report->id_user = auth()->id();  
        $report->viewed = false;

    
        switch ($validated['entity_type']) {
            case 'question':
                $report->id_question = $validated['id_entity'];
                break;
            case 'answer':
                $report->id_answer = $validated['id_entity'];
                break;
            case 'comment':
                $report->id_comment = $validated['id_entity'];
                break;
        }

        
        $report->save();

        switch ($validated['entity_type']) {
            case 'question':
                return redirect()->route('questions.show', ['id' => $validated['id_entity']])
                                 ->with('success', 'Report enviado com sucesso!');
            case 'answer':
                $answer = Answer::find($validated['id_entity']);
                return redirect()->route('questions.show', ['id' => $answer->id_question])
                         ->with('success', 'Report enviado com sucesso!');
                
        }
    }
}
