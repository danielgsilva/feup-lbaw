<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\HomeController;


use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\PasswordResetController;
use App\Http\Controllers\QuestionController;
use App\Http\Controllers\AnswerController;
use App\Http\Controllers\UserProfileController;
use App\Http\Controllers\CommentController;
use App\Http\Controllers\GoogleController;
use App\Http\Controllers\GitHubController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\PageController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\TagController;



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


// About us
Route::get('/about', [PageController::class, 'about']); 

// Main Features
Route::get('/features', [PageController::class, 'features']);


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

    Route::get('/questions/{id}/getVote', [QuestionController::class, 'getVote']);
});

// Answers
Route::controller(AnswerController::class)->group(function () {
    Route::get('/questions/{id}/answer/create', 'create')->name('answers.create');
    Route::get('/answers/{id}/comments', [AnswerController::class, 'showComments'])->name('answers.comments');
    Route::post('/answers', [AnswerController::class, 'store'])->name('answers.store');

    // Edit and delete answer
    Route::get('/answers/{id}/edit', [AnswerController::class, 'edit'])->name('answers.edit');
    Route::put('/answers/{id}', [AnswerController::class, 'update'])->name('answers.update');
    Route::delete('/answers/{id}', [AnswerController::class, 'destroy'])->name('answers.destroy');

    // Accept answer
    Route::post('/answers/{id}/accept', [AnswerController::class, 'accept'])->name('answers.accept');

    Route::get('/answers/{id}/getVote', [AnswerController::class, 'getVote']);
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
    Route::post('/comments', [CommentController::class, 'store'])->name('comments.store');
    Route::get('/notifications', [NotificationController::class, 'index'])->name('notifications.index');
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead'])->name('notifications.read');
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

// Password Reset
Route::controller(PasswordResetController::class)->group(function () {
    Route::get('/forgot-password', 'show')->name('password.request');
    Route::post('/forgot-password', 'requestRecovery')->name('password.email');
    Route::get('/reset-password/{token}', 'showResetPassword')->name('password.reset');
    Route::post('/reset-password', 'resetPassword')->name('password.update');
});

// User Profile
Route::controller(UserProfileController::class)->group(function () {
    Route::get('/profile/edit', [UserProfileController::class, 'editProfile'])->name('profile.edit');
    
Route::get('/profile/search', [UserProfileController::class, 'searchUsersPage'])->name('profile.searchPage');
Route::get('/profile/search/results', [UserProfileController::class, 'searchUsers'])->name('profile.searchResults');

    Route::patch('/profile/edit', [UserProfileController::class, 'updateProfile'])->name('profile.update');
    Route::get('/profile/{username}', [UserProfileController::class, 'showProfile'])->name('profile.show');
    Route::delete('/profile/{username}', [UserProfileController::class, 'deleteUser'])->name('profile.delete');
    Route::patch('/profile/{username}/ban', [UserProfileController::class, 'toggleBan'])->name('profile.toggleBan');
    Route::get('/profile/{username}/edit', [UserProfileController::class, 'editProfile'])
        ->name('profile.editAny');
    Route::patch('/profile/{username}', [UserProfileController::class, 'updateProfile'])
        ->name('profile.updateAny');
});

// Comments
Route::controller(CommentController::class)->group(function () {
    Route::post('/comments', 'store')->name('comments.store');
    Route::get('/comments/{id}/edit', 'edit')->name('comments.edit');
    Route::put('/comments/{id}', 'update')->name('comments.update');
    Route::delete('/comments/{id}', 'destroy')->name('comments.destroy');
    Route::get('/comments/{id}', 'show')->name('comments.show');
});

// Votes
Route::post('/questions/{id}/vote', [QuestionController::class, 'vote'])->name('questions.vote');

Route::post('/answers/{id}/vote', [AnswerController::class, 'vote'])->name('answers.vote');

// Google log in
Route::controller(GoogleController::class)->group(function () {
    Route::get('auth/google', 'redirect')->name('google-auth');
    Route::get('auth/google/call-back', 'callbackGoogle')->name('google-call-back');
});

// GitHub log in 
Route::controller(GitHubController::class)->group(function () {
    Route::get('auth/github', [GitHubController::class, 'redirect'])->name('github-auth');
    Route::get('auth/github/call-back', [GitHubController::class, 'callbackGitHub']);
});

// Reports
Route::controller(ReportController::class)->group(function () {
    Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
    Route::put('/reports/{report}/resolve', [ReportController::class, 'resolve'])->name('reports.resolve');
    Route::get('/report/{type}/{id}', [ReportController::class, 'create'])->name('report.create');
    Route::post('/report', [ReportController::class, 'store'])->name('report.store');
});


// Tags

Route::controller(TagController::class)->group(function () {
    Route::get('/tags/manage', 'index')->name('tags.index');
    Route::get('/tags/create', 'create')->name('tags.create');
    Route::post('/tags/create', 'store')->name('tags.store');
    Route::get('/tags/{tag}/edit', 'edit')->name('tags.edit');
    Route::patch('/tags/{tag}', 'update')->name('tags.update');
    Route::delete('/tags/{tag}', 'destroy')->name('tags.destroy');
    Route::get('/tasg/{id}', 'show')->name('tags.show');
});
