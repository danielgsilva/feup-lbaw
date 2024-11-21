<?php
namespace App\Http\Controllers;


class HomeController extends Controller
{
    /**
     * Show the homepage.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        // You can pass data to the view if needed
        return view('pages.home');
    }
}