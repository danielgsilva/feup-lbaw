<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\HomeController;


use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\QuestionController;
use App\Http\Controllers\AnswerController;
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
    Route::post('/questions', [QuestionController::class, 'store'])->name('questions.store');

    Route::get('/questions/search', [QuestionController::class, 'search'])->name('questions.search');

    Route::get('/questions/{id}/comments', [QuestionController::class, 'getComments']);
    Route::get('/questions/{id}', [QuestionController::class, 'show'])->name('questions.show');

    

    // Edit and delete question
    Route::get('/questions/{id}/edit', [QuestionController::class, 'edit'])->name('questions.edit');
    Route::put('/questions/{id}', [QuestionController::class, 'update'])->name('questions.update');
    Route::delete('/questions/{id}', [QuestionController::class, 'destroy'])->name('questions.destroy');
});

// Answers
Route::controller(AnswerController::class)->group(function () {
    Route::get('/questions/{id}/answer/create', 'create')->name('answers.create');
    Route::post('/answers', [AnswerController::class, 'store'])->name('answers.store');

    // Edit and delete answer
    Route::get('/answers/{id}/edit', [AnswerController::class, 'edit'])->name('answers.edit');
    Route::put('/answers/{id}', [AnswerController::class, 'update'])->name('answers.update');
    Route::delete('/answers/{id}', [AnswerController::class, 'destroy'])->name('answers.destroy');
});

// This are the routes that require authentication. If any other are added do not forget to add them here
Route::middleware(['auth'])->group(function () {
    Route::get('questions/create', [QuestionController::class, 'create'])->name('questions.create');
    Route::post('questions', [QuestionController::class, 'store'])->name('questions.store');
    Route::get('questions/{id}/edit', [QuestionController::class, 'edit'])->name('questions.edit');
    Route::put('questions/{id}', [QuestionController::class, 'update'])->name('questions.update');
    Route::delete('questions/{id}', [QuestionController::class, 'destroy'])->name('questions.destroy');
    Route::get('questions/{id}/answer/create', [AnswerController::class, 'create'])->name('answers.create');
    Route::post('answers', [AnswerController::class, 'store'])->name('answers.store');
    Route::get('answers/{id}/edit', [AnswerController::class, 'edit'])->name('answers.edit');
    Route::put('answers/{id}', [AnswerController::class, 'update'])->name('answers.update');
    Route::delete('answers/{id}', [AnswerController::class, 'destroy'])->name('answers.destroy');
    Route::get('/profile/{username}/edit', [UserProfileController::class, 'editProfile'])
        ->name('profile.editAny');
    Route::patch('/profile/{username}', [UserProfileController::class, 'updateProfile'])
        ->name('profile.updateAny');
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

// User Profile
Route::controller(UserProfileController::class)->group(function () {
    Route::get('/profile/edit', [UserProfileController::class, 'editProfile'])->name('profile.edit');
    Route::get('/profile/search', [UserProfileController::class, 'search'])->name('profile.search');
    Route::patch('/profile/edit', [UserProfileController::class, 'updateProfile'])->name('profile.update');
    Route::get('/profile/{username}', [UserProfileController::class, 'showProfile'])->name('profile.show');
    Route::delete('/profile/{username}', [UserProfileController::class, 'deleteUser'])->name('profile.delete');
    Route::patch('/profile/{username}/ban', [UserProfileController::class, 'toggleBan'])->name('profile.toggleBan');
    Route::get('/profile/{username}/edit', [UserProfileController::class, 'editProfile'])
        ->name('profile.editAny');
    Route::patch('/profile/{username}', [UserProfileController::class, 'updateProfile'])
        ->name('profile.updateAny');
});



// Votes
Route::post('/questions/{id}/vote', [QuestionController::class, 'vote'])->name('questions.vote');

//nao sei como fazer esta , tentei com /questions mas tbm nao funcionou
//deixo assim para parecer mais intuitivo o que faz
Route::post('/answers/{id}/vote', [AnswerController::class, 'vote'])->name('answers.vote');

