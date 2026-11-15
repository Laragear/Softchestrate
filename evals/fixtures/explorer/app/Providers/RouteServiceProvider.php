<?php
class RouteServiceProvider
{
    public function boot(): void
    {
        RateLimiter::for('api', fn ($request) => Limit::perMinute(60)->by($request->ip()));
    }
}
