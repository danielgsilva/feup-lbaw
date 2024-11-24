<?php

namespace App\Providers;

namespace App\Providers;

use App\Models\Answer;
use App\Models\Question;
use App\Policies\AnswerPolicy;
use App\Policies\QuestionPolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The model to policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        Answer::class => AnswerPolicy::class,
        Question::class => QuestionPolicy::class,
    ];

    /**
     * Register any authentication / authorization services.
     */
    public function boot(): void
    {
        $this->registerPolicies();
    }
}
