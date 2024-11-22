<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\HomeController;


use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\QuestionController;
use App\Http\Controllers\UserProfileController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

// Home
Route::redirect('/', '/home');

// Cards
Route::controller(HomeController::class)->group(function () {
    Route::get('/home', 'index')->name('home');
});


// Questions
Route::controller(QuestionController::class)->group(function () {
    // Create a new question
    Route::get('/questions/create', [QuestionController::class, 'create'])->name('questions.create');

    // View a specific question
    Route::get('/questions/{id}', [QuestionController::class, 'show'])->name('questions.show');


    // Route to handle form submission and store the new question
    Route::post('/questions', [QuestionController::class, 'store'])->name('questions.store');

});


// Authentication
Route::controller(LoginController::class)->group(function () {
    Route::get('/login', 'showLoginForm')->name('login');
    Route::post('/login', 'authenticate');
    Route::get('/logout', 'logout')->name('logout');
});

Route::controller(RegisterController::class)->group(function () {
    Route::get('/register', 'showRegistrationForm')->name('register');
    Route::post('/register', 'register');
});

Route::get('/profile/{username}', [UserProfileController::class, 'showProfile'])->name('profile.show');

Route::get('/profile/edit', [UserProfileController::class, 'editProfile'])->name('profile.edit');
Route::patch('/profile/edit', [UserProfileController::class, 'updateProfile'])->name('profile.update');